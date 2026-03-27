import Foundation
import Observation

/// Manages form state and submission for creating a new game listing.
@Observable
@MainActor
final class CreateGameViewModel {

    // MARK: Form fields

    var title: String = ""
    var description: String = ""
    var genre: String = Genre.allCases.first?.rawValue ?? ""
    var coinPrice: String = "0"
    var coverImageUrl: String = ""
    var creatorName: String = ""

    // MARK: Published state

    private(set) var isSubmitting = false
    private(set) var createdGame: Game?
    var errorMessage: String?

    // MARK: - Validation

    /// Returns true when all required fields are filled in.
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !description.trimmingCharacters(in: .whitespaces).isEmpty
            && !creatorName.trimmingCharacters(in: .whitespaces).isEmpty
            && Int(coinPrice.trimmingCharacters(in: .whitespaces)) != nil
    }

    // MARK: - Intent methods

    /// Submits the form to create a new game listing.
    func submit() async {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields."
            return
        }
        isSubmitting = true
        errorMessage = nil

        // Convert coin price to dollar-equivalent string for the backend
        let coins = Int(coinPrice.trimmingCharacters(in: .whitespaces)) ?? 0
        let dollarPrice = String(format: "%.2f", Double(coins) / 100.0)

        let body = CreateGameBody(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            genre: genre,
            price: dollarPrice,
            coverImageUrl: coverImageUrl.trimmingCharacters(in: .whitespaces).isEmpty
                ? nil
                : coverImageUrl.trimmingCharacters(in: .whitespaces),
            sellerName: creatorName.trimmingCharacters(in: .whitespaces)
        )
        do {
            createdGame = try await APIClient.shared.createGame(body)
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }

    /// Clears the success state after showing a confirmation.
    func clearCreatedGame() {
        createdGame = nil
    }

    // MARK: - Private helpers

    private func resetForm() {
        title = ""
        description = ""
        genre = Genre.allCases.first?.rawValue ?? ""
        coinPrice = "0"
        coverImageUrl = ""
        creatorName = ""
    }
}

// MARK: - Genre

/// Kid-friendly game genres (Horror excluded for under-13 audience).
enum Genre: String, CaseIterable, Identifiable {
    case action = "Action"
    case arcade = "Arcade"
    case adventure = "Adventure"
    case puzzle = "Puzzle"
    case rpg = "RPG"
    case strategy = "Strategy"
    case simulation = "Simulation"
    case sports = "Sports"
    case other = "Other"

    var id: String { rawValue }

    /// A fun emoji to represent this genre.
    var emoji: String {
        switch self {
        case .action: return "⚡"
        case .arcade: return "🕹️"
        case .adventure: return "🗺️"
        case .puzzle: return "🧩"
        case .rpg: return "🐉"
        case .strategy: return "♟️"
        case .simulation: return "🌍"
        case .sports: return "⚽"
        case .other: return "🎮"
        }
    }
}
