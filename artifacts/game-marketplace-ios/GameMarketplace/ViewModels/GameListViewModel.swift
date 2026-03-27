import Foundation
import Observation

/// Manages state for the game storefront list.
@Observable
@MainActor
final class GameListViewModel {

    // MARK: Published state

    private(set) var games: [Game] = []
    private(set) var isLoading = false
    var errorMessage: String?

    // MARK: - Intent methods

    /// Loads all games from the server.
    func loadGames() async {
        isLoading = true
        errorMessage = nil
        do {
            games = try await APIClient.shared.listGames()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
