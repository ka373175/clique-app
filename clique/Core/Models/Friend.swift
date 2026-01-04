//
//  Friend.swift
//  clique
//
//  Created by Clique on 1/4/26.
//

import Foundation

/// Represents a friend in the user's friends list
struct Friend: Codable, Identifiable {
    let id: String
    let username: String
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, firstName, lastName
    }
    
    /// Full display name
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    /// Initials for avatar display
    var initials: String {
        let firstInitial = firstName.first.map(String.init) ?? ""
        let lastInitial = lastName.first.map(String.init) ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
}
