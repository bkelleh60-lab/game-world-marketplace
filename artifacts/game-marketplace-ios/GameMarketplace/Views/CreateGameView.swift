import SwiftUI

/// A form screen where young game creators can list their own games.
struct CreateGameView: View {

    @State private var viewModel = CreateGameViewModel()
    @State private var showingSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                creatorSection
                gameInfoSection
                pricingSection
                mediaSection
                submitSection
            }
            .navigationTitle("🕹️ Create a Game")
            .navigationBarTitleDisplayMode(.large)
            .disabled(viewModel.isSubmitting)
            .alert("Game Added! 🎉", isPresented: $showingSuccess) {
                Button("Awesome!") { viewModel.clearCreatedGame() }
            } message: {
                Text("Your game is now in Game World for everyone to discover!")
            }
            .onChange(of: viewModel.createdGame) { _, newValue in
                if newValue != nil { showingSuccess = true }
            }
            .overlay {
                if viewModel.isSubmitting {
                    ProgressView("Adding your game…")
                        .padding(24)
                        .background(Material.regular)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    // MARK: - Form sections

    private var creatorSection: some View {
        Section {
            TextField("Your creator name", text: $viewModel.creatorName)
                .textInputAutocapitalization(.words)
        } header: {
            Text("👤 Creator Name")
        } footer: {
            Text("This is the name that will show on your game listing.")
        }
    }

    private var gameInfoSection: some View {
        Section("🎮 Game Details") {
            TextField("Game title", text: $viewModel.title)
            ZStack(alignment: .topLeading) {
                if viewModel.description.isEmpty {
                    Text("Tell players what your game is about!")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
            }
            Picker("Genre", selection: $viewModel.genre) {
                ForEach(Genre.allCases) { genre in
                    HStack {
                        Text(genre.emoji)
                        Text(genre.rawValue)
                    }
                    .tag(genre.rawValue)
                }
            }
        }
    }

    private var pricingSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("🪙")
                    .font(.title3)
                TextField("0", text: $viewModel.coinPrice)
                    .keyboardType(.numberPad)
                Text("coins")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("🪙 Coin Price")
        } footer: {
            Text("Set to 0 coins to share your game for free!")
        }
    }

    private var mediaSection: some View {
        Section {
            TextField("https://…", text: $viewModel.coverImageUrl)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        } header: {
            Text("🖼️ Cover Image (Optional)")
        } footer: {
            Text("Paste a link to an image that represents your game.")
        }
    }

    private var submitSection: some View {
        Section {
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button(action: { Task { await viewModel.submit() } }) {
                Label("Share My Game! 🚀", systemImage: "arrow.up.circle.fill")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
            }
            .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
        }
    }
}
