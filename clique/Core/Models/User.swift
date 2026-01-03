//
//  User.swift
//  clique
//
//  Created by Clique on 1/3/26.
//

import Foundation

/// Represents an authenticated user
struct User: Codable, Equatable {
    let id: String
    let username: String
    let firstName: String
    let lastName: String
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

/// Response from login/signup API calls
struct AuthResponse: Codable {
    let token: String
    let user: User
}
