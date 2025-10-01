//
//  APIClient.swift
//  clique
//
//  Created by Praveen Kumar on 9/30/25.
//

import Foundation

/// Centralized API client for simple GET / POST requests used by the app.
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
    case encodingError(Error)
    case urlSessionError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .statusCode(let code): return "Server returned status code \(code)"
        case .decodingError(let e): return "Failed to decode response: \(e.localizedDescription)"
        case .encodingError(let e): return "Failed to encode request: \(e.localizedDescription)"
        case .urlSessionError(let e): return e.localizedDescription
        }
    }
}

/// Lightweight type-erasure wrapper so we can encode `Encodable` values without knowing concrete type.
struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init<T: Encodable>(_ wrapped: T) {
        self._encode = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

final class APIClient {
    static let shared = APIClient()
    private let baseURL: URL
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init(baseURLString: String = API.baseURLString, session: URLSession = .shared) {
        // Ensure trailing slash
        var urlString = baseURLString
        if !urlString.hasSuffix("/") {
            urlString += "/"
        }
        guard let url = URL(string: urlString) else {
            fatalError("Invalid base URL in Constants")
        }
        self.baseURL = url
        self.session = session
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    /// Simple GET that decodes `T`.
    func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
        print("URL is \(url.absoluteString)")
        var request = URLRequest(url: url)
        print("Request is \(request)")
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.statusCode(httpResponse.statusCode)
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch {
            throw APIError.urlSessionError(error)
        }
    }

    /// POST without expecting a response body (only checks success status).
    func post(_ path: String, body: Encodable?) async throws {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
            } catch {
                throw APIError.encodingError(error)
            }
        }

        do {
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.statusCode(httpResponse.statusCode)
            }
        } catch {
            throw APIError.urlSessionError(error)
        }
    }

    /// POST expecting a decodable response of type T.
    func post<T: Decodable>(_ path: String, body: Encodable?) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
            } catch {
                throw APIError.encodingError(error)
            }
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.statusCode(httpResponse.statusCode)
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch {
            throw APIError.urlSessionError(error)
        }
    }
}
