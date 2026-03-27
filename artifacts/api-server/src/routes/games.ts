import { Router, type IRouter } from "express";
import { eq, desc } from "drizzle-orm";
import { db, gamesTable, purchasesTable } from "@workspace/db";
import {
  ListGamesQueryParams,
  ListGamesResponse,
  CreateGameBody,
  GetGameParams,
  GetGameResponse,
  UpdateGameParams,
  UpdateGameBody,
  UpdateGameResponse,
  DeleteGameParams,
  PurchaseGameParams,
  PurchaseGameBody,
} from "@workspace/api-zod";
const router: IRouter = Router();

router.get("/games", async (req, res): Promise<void> => {
  const queryParsed = ListGamesQueryParams.safeParse(req.query);
  if (!queryParsed.success) {
    res.status(400).json({ error: queryParsed.error.message });
    return;
  }

  const { sellerName } = queryParsed.data;

  const games = sellerName
    ? await db
        .select()
        .from(gamesTable)
        .where(eq(gamesTable.sellerName, sellerName))
        .orderBy(desc(gamesTable.createdAt))
    : await db.select().from(gamesTable).orderBy(desc(gamesTable.createdAt));

  res.json(ListGamesResponse.parse(games));
});

router.post("/games", async (req, res): Promise<void> => {
  const parsed = CreateGameBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  const [game] = await db.insert(gamesTable).values(parsed.data).returning();

  res.status(201).json(GetGameResponse.parse(game));
});

router.get("/games/:id", async (req, res): Promise<void> => {
  const params = GetGameParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: params.error.message });
    return;
  }

  const [game] = await db
    .select()
    .from(gamesTable)
    .where(eq(gamesTable.id, params.data.id));

  if (!game) {
    res.status(404).json({ error: "Game not found" });
    return;
  }

  res.json(GetGameResponse.parse(game));
});

router.patch("/games/:id", async (req, res): Promise<void> => {
  const params = UpdateGameParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: params.error.message });
    return;
  }

  const parsed = UpdateGameBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  const [game] = await db
    .update(gamesTable)
    .set(parsed.data)
    .where(eq(gamesTable.id, params.data.id))
    .returning();

  if (!game) {
    res.status(404).json({ error: "Game not found" });
    return;
  }

  res.json(UpdateGameResponse.parse(game));
});

router.delete("/games/:id", async (req, res): Promise<void> => {
  const params = DeleteGameParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: params.error.message });
    return;
  }

  const [deleted] = await db
    .delete(gamesTable)
    .where(eq(gamesTable.id, params.data.id))
    .returning();

  if (!deleted) {
    res.status(404).json({ error: "Game not found" });
    return;
  }

  res.sendStatus(204);
});

router.post("/games/:id/purchase", async (req, res): Promise<void> => {
  const params = PurchaseGameParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: params.error.message });
    return;
  }

  const parsed = PurchaseGameBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  const [game] = await db
    .select()
    .from(gamesTable)
    .where(eq(gamesTable.id, params.data.id));

  if (!game) {
    res.status(404).json({ error: "Game not found" });
    return;
  }

  const [purchase] = await db
    .insert(purchasesTable)
    .values({
      gameId: params.data.id,
      buyerName: parsed.data.buyerName,
    })
    .returning();

  res.status(201).json(purchase);
});

export default router;
