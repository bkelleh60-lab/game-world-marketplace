import SwiftUI

/// Full detail screen for a game listing, with a kid-friendly "Get Game!" action.
struct GameDetailView: View {
    let game: Game

    @State private var viewModel = GameDetailViewModel()
    @State private var showingClaimSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                coverImage
                details
            }
        }
        .navigationTitle(game.title)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingClaimSheet) {
            ClaimGameView(game: game, viewModel: viewModel)
        }
        .alert("Oops! 😬", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Cover image

    @ViewBuilder
    private var coverImage: some View {
        if let urlString = game.coverImageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(16 / 9, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                case .failure, .empty:
                    coverPlaceholder
                @unknown default:
                    coverPlaceholder
                }
            }
        } else {
            coverPlaceholder
        }
    }

    private var coverPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: genreGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(genreEmoji)
                .font(.system(size: 80))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
    }

    // MARK: - Details

    private var details: some View {
        VStack(alignment: .leading, spacing: 22) {

            // Title and coin price
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Label(game.creatorName, systemImage: "person.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(game.coinPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                }
            }

            // Genre badge
            HStack(spacing: 6) {
                Text(genreEmoji)
                Text(game.genre)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Color.accentColor.opacity(0.15))
            .foregroundStyle(.tint)
            .clipShape(Capsule())

            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("About this game")
                    .font(.headline)
                Text(game.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Get Game button
            Button {
                showingClaimSheet = true
            } label: {
                HStack(spacing: 8) {
                    Text("🎉")
                        .font(.title3)
                    Text("Get Game! — \(game.coinPrice)")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.orange)
        }
        .padding(20)
    }

    // MARK: - Helpers

    private var genreEmoji: String { Genre(rawValue: game.genre)?.emoji ?? "🎮" }

    private var genreGradient: [Color] {
        switch game.genre {
        case "Action":    return [.red.opacity(0.6), .orange.opacity(0.7)]
        case "Arcade":    return [.purple.opacity(0.6), .pink.opacity(0.7)]
        case "Adventure": return [.green.opacity(0.6), .teal.opacity(0.7)]
        case "Puzzle":    return [.blue.opacity(0.6), .cyan.opacity(0.7)]
        case "RPG":       return [.indigo.opacity(0.6), .purple.opacity(0.7)]
        case "Strategy":  return [.brown.opacity(0.5), .orange.opacity(0.6)]
        case "Simulation":return [.teal.opacity(0.6), .green.opacity(0.7)]
        case "Sports":    return [.green.opacity(0.7), .yellow.opacity(0.6)]
        default:          return [.blue.opacity(0.5), .purple.opacity(0.6)]
        }
    }
}
