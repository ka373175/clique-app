//
//  FriendRequest.swift
//  clique
//
//  Created by Clique on 1/7/26.
//

import Foundation

/// Represents a pending friend request
struct FriendRequest: Codable, Identifiable {
    let id: String           // friendship _id
    let requesterId: String
    let username: String
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case requesterId
        case username
        case firstName
        case lastName
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
