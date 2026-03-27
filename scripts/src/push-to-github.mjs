import { ReplitConnectors } from "@replit/connectors-sdk";
import { readFileSync, readdirSync, statSync } from "fs";
import { join, relative } from "path";

const connectors = new ReplitConnectors();
const OWNER = "bkelleh60-lab";
const REPO = "game-world-marketplace";
const ROOT = "/home/runner/workspace";

const IGNORE = [
  "node_modules", ".git", ".local", "dist", ".cache",
  "generated", "__pycache__", "drizzle",
];

function getAllFiles(dir, base = ROOT) {
  const results = [];
  for (const entry of readdirSync(dir)) {
    if (IGNORE.includes(entry)) continue;
    const full = join(dir, entry);
    const rel = relative(base, full);
    const stat = statSync(full);
    if (stat.isDirectory()) {
      results.push(...getAllFiles(full, base));
    } else {
      results.push(rel);
    }
  }
  return results;
}

async function ghApi(path, options = {}) {
  const response = await connectors.proxy("github", path, {
    ...options,
    headers: { "Content-Type": "application/json", ...options.headers },
  });
  if (!response.ok) {
    const body = await response.text();
    throw new Error(`GitHub API error ${response.status} for ${path}: ${body}`);
  }
  return response.json();
}

async function main() {
  // Initialize repo with a README so it's no longer empty
  console.log("Initializing repo with first commit...");
  const readmeContent = Buffer.from("# Game World Marketplace\n\nInitializing...\n").toString("base64");
  await ghApi(`/repos/${OWNER}/${REPO}/contents/README.md`, {
    method: "PUT",
    body: JSON.stringify({
      message: "init",
      content: readmeContent,
    }),
  });

  // Get the SHA of the initial commit
  const mainRef = await ghApi(`/repos/${OWNER}/${REPO}/git/ref/heads/main`);
  const baseSha = mainRef.object.sha;
  console.log("Base commit SHA:", baseSha);

  const files = getAllFiles(ROOT);
  console.log(`\nFound ${files.length} files to push...`);

  // Create blobs for all files
  const treeItems = [];
  let i = 0;
  for (const filePath of files) {
    i++;
    const fullPath = join(ROOT, filePath);
    let content;
    let encoding = "utf-8";

    try {
      content = readFileSync(fullPath, "utf-8");
    } catch {
      // Binary file — skip
      console.log(`  Skipping binary: ${filePath}`);
      continue;
    }

    try {
      const blob = await ghApi(`/repos/${OWNER}/${REPO}/git/blobs`, {
        method: "POST",
        body: JSON.stringify({ content, encoding }),
      });

      treeItems.push({
        path: filePath,
        mode: "100644",
        type: "blob",
        sha: blob.sha,
      });

      if (i % 20 === 0 || i === files.length) {
        console.log(`  ${i}/${files.length} blobs created...`);
      }
    } catch (err) {
      console.warn(`  Warning: Could not create blob for ${filePath}: ${err.message}`);
    }
  }

  console.log(`\nCreating tree with ${treeItems.length} items...`);
  const tree = await ghApi(`/repos/${OWNER}/${REPO}/git/trees`, {
    method: "POST",
    body: JSON.stringify({ tree: treeItems }),
  });

  console.log("Creating commit...");
  const commit = await ghApi(`/repos/${OWNER}/${REPO}/git/commits`, {
    method: "POST",
    body: JSON.stringify({
      message: "feat: Game World Marketplace — kid-friendly iOS app + Express/PostgreSQL API",
      tree: tree.sha,
      parents: [baseSha],
    }),
  });

  console.log("Updating main branch ref...");
  await ghApi(`/repos/${OWNER}/${REPO}/git/refs/heads/main`, {
    method: "PATCH",
    body: JSON.stringify({
      sha: commit.sha,
      force: true,
    }),
  });

  console.log(`\nDone! Repo live at: https://github.com/${OWNER}/${REPO}`);
}

main().catch((err) => {
  console.error("Push failed:", err.message);
  process.exit(1);
});
