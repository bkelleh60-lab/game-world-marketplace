import SwiftUI

/// A colorful card displaying a game listing — designed for young players.
struct GameCardView: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            coverImage
            info
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var coverImage: some View {
        if let urlString = game.coverImageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(16 / 9, contentMode: .fill)
                case .failure, .empty:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
            .frame(height: 130)
            .clipped()
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                colors: genreGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(genreEmoji)
                .font(.system(size: 48))
        }
        .frame(height: 130)
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(game.title)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)

            HStack(spacing: 4) {
                Text(genreEmoji)
                Text(game.genre)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label(game.creatorName, systemImage: "person.fill")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(game.coinPrice)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            }
        }
        .padding(12)
    }

    // MARK: - Helpers

    private var genreEmoji: String {
        Genre(rawValue: game.genre)?.emoji ?? "🎮"
    }

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
