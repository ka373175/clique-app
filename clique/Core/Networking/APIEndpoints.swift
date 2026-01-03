//
//  APIEndpoints.swift
//  clique
//
//  Created by Clique on 1/3/26.
//

import Foundation

/// Centralized API endpoints for the Clique app
enum APIEndpoints {
    static let baseURL = "https://60q4fmxnb7.execute-api.us-east-2.amazonaws.com/prod"
    
    static let statuses = "\(baseURL)/statuses"
    static let addUser = "\(baseURL)/add-user"
    static let login = "\(baseURL)/login"
    static let signup = "\(baseURL)/signup"
    
    static func updateStatus(userId: String) -> String {
        return "\(baseURL)/update-status/\(userId)"
    }
    
    static var updateStatus: String {
        return "\(baseURL)/update-status"
    }
}

