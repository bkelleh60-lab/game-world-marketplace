import Foundation

/// Represents a completed (simulated) game purchase.
struct Purchase: Identifiable, Codable, Sendable {
    let id: Int
    let gameId: Int
    let buyerName: String
    let purchasedAt: Date
}

/// Data required to record a purchase.
struct PurchaseGameBody: Encodable, Sendable {
    let buyerName: String
}
