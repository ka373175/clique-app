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
    
    private init() {}
    
    /// Fetches all statuses from the API
    func fetchStatuses() async throws -> [FullStatus] {
        guard let url = URL(string: APIEndpoints.statuses) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode([FullStatus].self, from: data)
    }
    
    /// Adds a new user with the given username
    func addUser(username: String) async throws {
        guard let url = URL(string: APIEndpoints.addUser) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
    }
    
    /// Updates the status for a given user
    func updateStatus(userId: String, emoji: String, text: String) async throws {
        guard let url = URL(string: APIEndpoints.updateStatus(userId: userId)) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "statusEmoji": emoji,
            "statusText": text
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
    }
}

/// API-related errors
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .requestFailed:
            return "Request failed"
        }
    }
}
