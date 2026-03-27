import Foundation
import Observation

/// Manages state for a single game detail screen, including claiming the game.
@Observable
@MainActor
final class GameDetailViewModel {

    // MARK: Published state

    private(set) var game: Game?
    private(set) var isLoading = false
    private(set) var isClaiming = false
    private(set) var claimed = false
    var errorMessage: String?

    // MARK: - Intent methods

    /// Loads the full details of a game by its identifier.
    func loadGame(id: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            game = try await APIClient.shared.getGame(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Records a claim for the current game. No personal data is collected.
    func claimGame() async {
        guard let game else { return }
        isClaiming = true
        errorMessage = nil
        do {
            _ = try await APIClient.shared.claimGame(id: game.id)
            claimed = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isClaiming = false
    }

    /// Resets the claimed state (e.g. to dismiss the success sheet).
    func clearClaimed() {
        claimed = false
    }
}
