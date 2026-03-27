import Foundation

/// Represents a game listing in the marketplace.
struct Game: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let title: String
    let description: String
    let genre: String
    /// Price stored as a decimal string, e.g. "4.99"
    let price: String
    let coverImageUrl: String?
    let sellerName: String
    let createdAt: Date

    /// Creator display name (alias for sellerName, used in kid-friendly UI).
    var creatorName: String { sellerName }

    /// Coin price for kids — converts dollar amount to whole coins (e.g. "$2.99" → "299 coins").
    var coinPrice: String {
        guard let value = Double(price) else { return "Free" }
        if value == 0 { return "Free 🎉" }
        let coins = Int(value * 100)
        return "\(coins) 🪙"
    }

    /// Returns true if this game has a valid cover image URL.
    var hasCoverImage: Bool {
        guard let urlString = coverImageUrl, !urlString.isEmpty else { return false }
        return URL(string: urlString) != nil
    }
}

// MARK: - Request bodies

/// Data required to create a new game listing.
struct CreateGameBody: Encodable, Sendable {
    let title: String
    let description: String
    let genre: String
    let price: String
    let coverImageUrl: String?
    let sellerName: String
}

/// Partial update fields for an existing game listing.
struct UpdateGameBody: Encodable, Sendable {
    var title: String?
    var description: String?
    var genre: String?
    var price: String?
    var coverImageUrl: String?
}
