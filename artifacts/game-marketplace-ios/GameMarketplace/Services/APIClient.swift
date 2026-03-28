import Foundation

// MARK: - Configuration

/// Central configuration for the API client.
/// Update `baseURL` to point to your deployed Replit backend.
enum APIConfiguration {
    /// The base URL of the backend API.
    /// Replace this with your Replit deployment domain, e.g.:
    ///   "https://your-replit-username.replit.app/api"
    static let baseURL: URL = URL(string: "https://your-replit-domain.replit.app/api")!
}

// MARK: - Errors

/// Errors that can be thrown by `APIClient`.
enum APIError: LocalizedError, Sendable {
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpError(let code, let message):
            return message.isEmpty ? "Server error (HTTP \(code))." : message
        case .decodingFailed(let error):
            return "Failed to decode server response: \(error.localizedDescription)"
        }
    }
}

// MARK: - APIClient

/// Centralized async/await API client for the Game Marketplace backend.
actor APIClient {

    // MARK: Singleton

    static let shared = APIClient()

    // MARK: Private properties

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    // MARK: Initializer

    private init() {
        session = URLSession.shared

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let formatterNoFraction = ISO8601DateFormatter()
        formatterNoFraction.formatOptions = [.withInternetDateTime]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = formatter.date(from: dateString) { return date }
            if let date = formatterNoFraction.date(from: dateString) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot parse date: \(dateString)"
            )
        }

        encoder = JSONEncoder()
        // API expects camelCase keys (sellerName, coverImageUrl, etc.) — no key conversion
        encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Game endpoints

    /// Fetches all game listings, optionally filtered by creator name.
    func listGames(creatorName: String? = nil) async throws -> [Game] {
        var components = URLComponents(
            url: APIConfiguration.baseURL.appendingPathComponent("games"),
            resolvingAgainstBaseURL: false
        )!
        if let creatorName, !creatorName.isEmpty {
            components.queryItems = [URLQueryItem(name: "sellerName", value: creatorName)]
        }
        guard let url = components.url else { throw APIError.invalidResponse }
        return try await get(url: url)
    }

    /// Fetches a single game by its identifier.
    func getGame(id: Int) async throws -> Game {
        let url = APIConfiguration.baseURL.appendingPathComponent("games/\(id)")
        return try await get(url: url)
    }

    /// Creates a new game listing and returns the created game.
    func createGame(_ body: CreateGameBody) async throws -> Game {
        let url = APIConfiguration.baseURL.appendingPathComponent("games")
        return try await post(url: url, body: body)
    }

    /// Updates an existing game listing and returns the updated game.
    func updateGame(id: Int, body: UpdateGameBody) async throws -> Game {
        let url = APIConfiguration.baseURL.appendingPathComponent("games/\(id)")
        return try await patch(url: url, body: body)
    }

    /// Deletes a game listing by its identifier.
    func deleteGame(id: Int) async throws {
        let url = APIConfiguration.baseURL.appendingPathComponent("games/\(id)")
        try await delete(url: url)
    }

    /// Records a game claim without collecting any personal information from the player.
    func claimGame(id: Int) async throws -> Purchase {
        let url = APIConfiguration.baseURL.appendingPathComponent("games/\(id)/purchase")
        // No personal data is sent — "Player" is a generic anonymous identifier.
        return try await post(url: url, body: PurchaseGameBody(buyerName: "Player"))
    }

    // MARK: - Private HTTP helpers

    private func get<Response: Decodable>(url: URL) async throws -> Response {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await perform(request: request)
    }

    private func post<Response: Decodable, Body: Encodable>(
        url: URL,
        body: Body
    ) async throws -> Response {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try encoder.encode(body)
        return try await perform(request: request)
    }

    private func patch<Response: Decodable, Body: Encodable>(
        url: URL,
        body: Body
    ) async throws -> Response {
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try encoder.encode(body)
        return try await perform(request: request)
    }

    private func delete(url: URL) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = extractErrorMessage(from: data)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }
    }

    private func perform<Response: Decodable>(request: URLRequest) async throws -> Response {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = extractErrorMessage(from: data)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(underlying: error)
        }
    }

    private func extractErrorMessage(from data: Data) -> String {
        if let body = try? JSONDecoder().decode([String: String].self, from: data),
           let error = body["error"] {
            return error
        }
        return ""
    }
}
