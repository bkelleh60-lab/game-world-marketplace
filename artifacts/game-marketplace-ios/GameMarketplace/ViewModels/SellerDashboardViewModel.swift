import Foundation
import Observation

/// Manages state for the creator dashboard, showing a creator's own game listings.
@Observable
@MainActor
final class SellerDashboardViewModel {

    // MARK: Published state

    private(set) var games: [Game] = []
    private(set) var isLoading = false
    var errorMessage: String?
    var creatorName: String = ""

    // MARK: - Intent methods

    /// Loads games for the current creator name.
    func loadGames() async {
        let trimmed = creatorName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            games = []
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            games = try await APIClient.shared.listGames(creatorName: trimmed)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Deletes a game listing and removes it from the local list.
    func deleteGame(id: Int) async {
        errorMessage = nil
        do {
            try await APIClient.shared.deleteGame(id: id)
            games.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Updates a game listing in place.
    func updateGame(id: Int, body: UpdateGameBody) async {
        errorMessage = nil
        do {
            let updated = try await APIClient.shared.updateGame(id: id, body: body)
            if let index = games.firstIndex(where: { $0.id == id }) {
                games[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
