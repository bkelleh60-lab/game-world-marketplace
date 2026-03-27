import SwiftUI

/// A screen where creators can manage their own game listings.
struct SellerDashboardView: View {

    @State private var viewModel = SellerDashboardViewModel()
    @State private var editingGame: Game?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                creatorNameField
                Divider()
                content
            }
            .navigationTitle("⭐ My Games")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.loadGames() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .fontWeight(.semibold)
                    }
                    .disabled(viewModel.creatorName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(item: $editingGame) { game in
                EditGameView(game: game) { updatedBody in
                    await viewModel.updateGame(id: game.id, body: updatedBody)
                }
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
    }

    // MARK: - Creator name input

    private var creatorNameField: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundStyle(.secondary)
            TextField("Enter your creator name", text: $viewModel.creatorName)
                .textInputAutocapitalization(.words)
                .submitLabel(.search)
                .onSubmit {
                    Task { await viewModel.loadGames() }
                }
            if !viewModel.creatorName.isEmpty {
                Button {
                    Task { await viewModel.loadGames() }
                } label: {
                    Text("Find")
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading your games…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.creatorName.trimmingCharacters(in: .whitespaces).isEmpty {
            promptView
        } else if viewModel.games.isEmpty {
            emptyView
        } else {
            gameList
        }
    }

    // MARK: - Game list with swipe actions

    private var gameList: some View {
        List {
            Section("\(viewModel.games.count) game(s) by \"\(viewModel.creatorName)\"") {
                ForEach(viewModel.games) { game in
                    DashboardGameRow(game: game)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await viewModel.deleteGame(id: game.id) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                editingGame = game
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - State views

    private var promptView: some View {
        ContentUnavailableView(
            "Who are you? 👋",
            systemImage: "person.crop.circle.badge.questionmark",
            description: Text("Type your creator name above to see your games!")
        )
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Games Yet 🎨",
            systemImage: "tray",
            description: Text("You haven't shared any games as \"\(viewModel.creatorName)\" yet.\nGo create one!")
        )
    }
}

// MARK: - Dashboard game row

private struct DashboardGameRow: View {
    let game: Game

    var body: some View {
        HStack(spacing: 14) {
            coverThumbnail
            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text(Genre(rawValue: game.genre)?.emoji ?? "🎮")
                    Text(game.genre)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(game.coinPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var coverThumbnail: some View {
        if let urlString = game.coverImageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    placeholderThumbnail
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            placeholderThumbnail
        }
    }

    private var placeholderThumbnail: some View {
        ZStack {
            Color.orange.opacity(0.15)
            Text(Genre(rawValue: game.genre)?.emoji ?? "🎮")
                .font(.title2)
        }
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
