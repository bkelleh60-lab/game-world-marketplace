import SwiftUI

/// A sheet for editing an existing game listing.
struct EditGameView: View {
    let game: Game
    var onSave: (UpdateGameBody) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    @State private var genre: String
    @State private var coinPrice: String
    @State private var coverImageUrl: String
    @State private var isSaving = false

    init(game: Game, onSave: @escaping (UpdateGameBody) async -> Void) {
        self.game = game
        self.onSave = onSave
        _title = State(initialValue: game.title)
        _description = State(initialValue: game.description)
        _genre = State(initialValue: game.genre)
        // Convert stored dollar price back to coins for display
        let coins = Int((Double(game.price) ?? 0) * 100)
        _coinPrice = State(initialValue: "\(coins)")
        _coverImageUrl = State(initialValue: game.coverImageUrl ?? "")
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && Int(coinPrice.trimmingCharacters(in: .whitespaces)) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("🎮 Game Details") {
                    TextField("Game title", text: $title)
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Tell players what your game is about!")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                    Picker("Genre", selection: $genre) {
                        ForEach(Genre.allCases) { genre in
                            HStack {
                                Text(genre.emoji)
                                Text(genre.rawValue)
                            }
                            .tag(genre.rawValue)
                        }
                    }
                }

                Section {
                    HStack(spacing: 8) {
                        Text("🪙")
                            .font(.title3)
                        TextField("0", text: $coinPrice)
                            .keyboardType(.numberPad)
                        Text("coins")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("🪙 Coin Price")
                }

                Section {
                    TextField("https://…", text: $coverImageUrl)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("🖼️ Cover Image (Optional)")
                }
            }
            .navigationTitle("Edit Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isFormValid || isSaving)
                        .fontWeight(.bold)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView("Saving…")
                        .padding(24)
                        .background(Material.regular)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    // MARK: - Helpers

    private func save() {
        isSaving = true
        let coins = Int(coinPrice.trimmingCharacters(in: .whitespaces)) ?? 0
        let dollarPrice = String(format: "%.2f", Double(coins) / 100.0)
        let body = UpdateGameBody(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            genre: genre,
            price: dollarPrice,
            coverImageUrl: coverImageUrl.trimmingCharacters(in: .whitespaces).isEmpty
                ? nil
                : coverImageUrl.trimmingCharacters(in: .whitespaces)
        )
        Task {
            await onSave(body)
            isSaving = false
            dismiss()
        }
    }
}
