import SwiftUI

/// The main storefront — a colorful, kid-friendly game discovery screen.
struct GameListView: View {

    @State private var viewModel = GameListViewModel()
    @State private var searchText = ""

    private var filteredGames: [Game] {
        guard !searchText.isEmpty else { return viewModel.games }
        return viewModel.games.filter { game in
            game.title.localizedCaseInsensitiveContains(searchText)
                || game.genre.localizedCaseInsensitiveContains(searchText)
                || game.creatorName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("🎮 Game World")
                .searchable(text: $searchText, prompt: "Search for a game…")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            Task { await viewModel.loadGames() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .fontWeight(.semibold)
                        }
                    }
                }
                .task { await viewModel.loadGames() }
                .refreshable { await viewModel.loadGames() }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Loading games…")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            errorView(message: error)
        } else if filteredGames.isEmpty {
            emptyView
        } else {
            gameGrid
        }
    }

    // MARK: - Game grid (adaptive for iPhone and iPad)

    private var gameGrid: some View {
        ScrollView {
            LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                ForEach(filteredGames) { game in
                    NavigationLink(destination: GameDetailView(game: game)) {
                        GameCardView(game: game)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private var adaptiveColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 160, maximum: 300), spacing: 16)]
    }

    // MARK: - State views

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Games Yet!", systemImage: "gamecontroller")
        } description: {
            Text("Be the first to share a game with the world! 🚀")
        }
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Oops! 😬", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task { await viewModel.loadGames() }
            }
            .buttonStyle(.bordered)
        }
    }
}
