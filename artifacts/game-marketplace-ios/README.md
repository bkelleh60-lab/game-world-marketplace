# Game World — iOS App for Kids (Swift/SwiftUI)

A native iOS app for kids under 13 to discover, claim, and create games. Built with SwiftUI, following the official [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).

## Kid-Friendly Design (Under 13)

- **No personal data collected** — claiming a game requires zero name entry or account info (COPPA-friendly)
- **Coin pricing** — prices shown in fun virtual coins instead of real money (e.g. "299 🪙" instead of "$2.99")
- **Age-appropriate genres** — Horror removed; genres are Action, Arcade, Adventure, Puzzle, RPG, Strategy, Simulation, Sports
- **Friendly language** — "Get Game!" instead of "Buy Now", "Creator" instead of "Seller", "My Games" instead of "Dashboard", "Game World" as the app name
- **Colorful UI** — genre-themed gradient placeholder images, emoji genre icons, orange accent color

## Requirements

- Xcode 15 or later
- iOS 17+ deployment target
- iPhone or iPad (simulator or physical device)

## Project Structure

```
GameMarketplace/
├── App/
│   ├── GameMarketplaceApp.swift    # @main entry point
│   └── ContentView.swift           # Adaptive root view (iPhone tabs / iPad sidebar)
├── Models/
│   ├── Game.swift                  # Game struct + request bodies
│   └── Purchase.swift              # Purchase struct + request body
├── Services/
│   └── APIClient.swift             # async/await API client (URLSession)
├── ViewModels/
│   ├── GameListViewModel.swift     # Storefront state
│   ├── GameDetailViewModel.swift   # Game detail + purchase state
│   ├── CreateGameViewModel.swift   # Create listing form state + Genre enum
│   └── SellerDashboardViewModel.swift  # Seller management state
└── Views/
    ├── GameCardView.swift          # Reusable card component
    ├── GameListView.swift          # Storefront grid (adaptive columns)
    ├── GameDetailView.swift        # Full game info + buy button
    ├── PurchaseConfirmationView.swift  # Purchase sheet with success state
    ├── CreateGameView.swift        # New listing form
    ├── EditGameView.swift          # Edit existing listing sheet
    └── SellerDashboardView.swift   # Manage seller's listings
```

## Setting Up in Xcode

1. **Open Xcode** and choose **File → New → Project**.
2. Select **iOS → App**.
3. Fill in the project settings:
   - **Product Name**: `GameMarketplace`
   - **Team**: Your Apple developer team (or Personal Team for simulator)
   - **Bundle Identifier**: e.g. `com.yourname.GameMarketplace`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Minimum Deployments**: iOS 17.0
4. Save the project in this directory (or move the generated project file here).
5. **Delete** the default `ContentView.swift` that Xcode generates.
6. **Add all Swift files** from this folder into the project:
   - In Xcode's Project Navigator, right-click the `GameMarketplace` folder.
   - Choose **Add Files to "GameMarketplace"**.
   - Select all `.swift` files from `App/`, `Models/`, `Services/`, `ViewModels/`, and `Views/`.
   - Make sure **"Copy items if needed"** is unchecked (the files are already in place).

## Configuring the API URL

Open `GameMarketplace/Services/APIClient.swift` and update the `baseURL`:

```swift
enum APIConfiguration {
    static let baseURL: URL = URL(string: "https://YOUR-REPLIT-DOMAIN.replit.app/api")!
}
```

Replace `YOUR-REPLIT-DOMAIN` with your actual Replit deployment subdomain.

For **local development** (if running the API locally on your Mac), use:

```swift
static let baseURL: URL = URL(string: "http://localhost:PORT/api")!
```

where `PORT` is the port your API server is listening on.

> **Note:** iOS requires HTTPS for network requests to remote servers. For local development with HTTP, add an App Transport Security exception in `Info.plist`.

## Running the App

1. Select your target device or simulator in Xcode's toolbar.
2. Press **⌘R** to build and run.
3. The app adapts automatically:
   - **iPhone**: Tab bar with Browse, Sell, and Dashboard tabs.
   - **iPad**: Sidebar navigation with the same three sections.

## Features

| Screen | Description |
|--------|-------------|
| **Browse** | Scrollable adaptive grid of all game listings. Search by title, genre, or seller. Tap a card to see full details. |
| **Game Detail** | Cover image, description, genre badge, price, and a "Buy Now" button that opens the purchase sheet. |
| **Purchase** | Sheet where the buyer enters their name and confirms. Shows a success animation on completion. |
| **List a Game** | Form with title, description, genre picker, price, cover image URL, and seller name. |
| **Dashboard** | Enter your seller name to see your listings. Swipe left to delete, swipe right to edit. |

## Swift Coding Standards

This codebase follows the official [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/):

- **Naming**: Clear, full English words; no abbreviations. Methods that return values use noun-based names; methods with side effects use verb-based names.
- **Types**: `struct` for all value types (models, request bodies); `class` only for `@Observable` view models that require reference semantics.
- **Concurrency**: `async/await` throughout; `actor` for the shared `APIClient` to ensure thread safety.
- **Error handling**: Typed `APIError` enum with `LocalizedError` conformance; errors surface clearly in the UI via `errorMessage` state.
- **Access control**: `private(set)` for published view model state; `private` for internal helpers.
