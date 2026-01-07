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
    
    /// Memberwise initializer for creating Friend instances
    init(id: String, username: String, firstName: String, lastName: String) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
    }
    
    /// Codable initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
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
