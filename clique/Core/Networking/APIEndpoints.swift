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
    static let refreshToken = "\(baseURL)/refresh-token"
    
    static var updateStatus: String {
        return "\(baseURL)/update-status"
    }
    
    static let friends = "\(baseURL)/friends"
    static let addFriend = "\(baseURL)/add-friend"
    static let removeFriend = "\(baseURL)/remove-friend"
}

