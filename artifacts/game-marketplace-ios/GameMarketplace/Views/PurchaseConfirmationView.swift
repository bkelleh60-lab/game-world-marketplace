import SwiftUI

/// A fun, one-tap sheet for claiming a game — no personal information required.
struct ClaimGameView: View {
    let game: Game
    var viewModel: GameDetailViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.claimed {
                    successView
                } else {
                    confirmView
                }
            }
            .navigationTitle("Get This Game!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not Now") {
                        viewModel.clearClaimed()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Confirm view (one-tap, no personal info)

    private var confirmView: some View {
        VStack(spacing: 28) {
            Spacer()

            // Game preview card
            VStack(spacing: 12) {
                Text(Genre(rawValue: game.genre)?.emoji ?? "🎮")
                    .font(.system(size: 64))

                Text(game.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("by \(game.creatorName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(game.coinPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            // Big, friendly button — no name needed
            Button(action: claimGame) {
                Group {
                    if viewModel.isClaiming {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("🎉 Get It!")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.orange)
            .disabled(viewModel.isClaiming)

            Spacer()
        }
        .padding(20)
    }

    // MARK: - Success view

    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🎊")
                .font(.system(size: 80))

            VStack(spacing: 10) {
                Text("You got it!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("**\(game.title)** is yours!\nHave fun playing! 🎮")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Awesome! ✨") {
                viewModel.clearClaimed()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.orange)

            Spacer()
        }
        .padding(20)
    }

    // MARK: - Helpers

    private func claimGame() {
        Task { await viewModel.claimGame() }
    }
}
