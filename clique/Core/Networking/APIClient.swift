//
//  APIClient.swift
//  clique
//
//  Created by Clique on 1/3/26.
//

import Foundation

/// A centralized API client for making network requests
actor APIClient {
    static let shared = APIClient()
    
    // MARK: - Shared Coders (avoid repeated allocation)
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    private init() {}
    
    // MARK: - Authentication
    
    /// Logs in a user with the given credentials
    func login(username: String, password: String) async throws -> AuthResponse {
        guard let url = URL(string: APIEndpoints.login) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LoginRequest(username: username, password: password)
        request.httpBody = try jsonEncoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.invalidCredentials
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
        
        return try jsonDecoder.decode(AuthResponse.self, from: data)
    }
    
    /// Signs up a new user
    func signup(username: String, password: String, firstName: String, lastName: String) async throws -> AuthResponse {
        guard let url = URL(string: APIEndpoints.signup) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = SignupRequest(username: username, password: password, firstName: firstName, lastName: lastName)
        request.httpBody = try jsonEncoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 409 {
            throw APIError.usernameExists
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
        
        return try jsonDecoder.decode(AuthResponse.self, from: data)
    }
    
    /// Refreshes the current JWT token, returning a new token if still valid
    func refreshToken(currentToken: String) async throws -> AuthResponse {
        guard let url = URL(string: APIEndpoints.refreshToken) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(currentToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
        
        return try jsonDecoder.decode(AuthResponse.self, from: data)
    }
    
    // MARK: - Statuses
    
    /// Fetches all statuses from the API (requires authentication)
    func fetchStatuses() async throws -> [FullStatus] {
        guard let url = URL(string: APIEndpoints.statuses) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        try await addAuthHeader(to: &request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        return try jsonDecoder.decode([FullStatus].self, from: data)
    }
    
    /// Adds a new user with the given username
    func addUser(username: String) async throws {
        guard let url = URL(string: APIEndpoints.addUser) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try await addAuthHeader(to: &request)
        
        let body = AddUserRequest(username: username)
        request.httpBody = try jsonEncoder.encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
    }
    
    /// Updates the status for the authenticated user
    func updateStatus(emoji: String, text: String) async throws {
        guard let url = URL(string: APIEndpoints.updateStatus) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try await addAuthHeader(to: &request)
        
        let body = UpdateStatusRequest(statusEmoji: emoji, statusText: text)
        request.httpBody = try jsonEncoder.encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
    }
    
    // MARK: - Private Helpers
    
    /// Adds the Authorization header with the JWT token
    private func addAuthHeader(to request: inout URLRequest) async throws {
        guard let token = await MainActor.run(body: { AuthService.shared.token }) else {
            throw APIError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

/// API-related errors
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed
    case invalidCredentials
    case usernameExists
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .requestFailed:
            return "Request failed"
        case .invalidCredentials:
            return "Invalid username or password"
        case .usernameExists:
            return "Username already exists"
        case .unauthorized:
            return "Please log in to continue"
        }
    }
}

// MARK: - Request Body Types

private struct LoginRequest: Encodable {
    let username: String
    let password: String
}

private struct SignupRequest: Encodable {
    let username: String
    let password: String
    let firstName: String
    let lastName: String
}

private struct AddUserRequest: Encodable {
    let username: String
}

private struct UpdateStatusRequest: Encodable {
    let statusEmoji: String
    let statusText: String
}
