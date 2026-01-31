//
//  Status.swift
//  clique
//
//  Created by Praveen Kumar on 8/13/25.
//

import Foundation

struct FullStatus: Codable, Hashable, Identifiable {
    /*
     id: string
     Identifier for swift to conform to Identifiable protocol
     */
    let id: String
    
    /*
     statusText: string
     The status of the user
     */
    let statusText: String
    
    /*
     statusEmoji: string?
     The emoji for the user's status
     */
    let statusEmoji: String?
    
    /*
     firstName: string
     The first name of the user
     */
    let firstName: String
    
    /*
     lastName: string
     The last name of the user
     */
    let lastName: String
    
    /*
     isCurrentUser: bool
     Whether this status belongs to the authenticated user
     */
    let isCurrentUser: Bool
    
    /*
     iconColor: string?
     The user's selected icon background color
     */
    let iconColor: String?
    
    /*
     latitude: double?
     The user's latitude coordinate when sharing location
     */
    let latitude: Double?
    
    /*
     longitude: double?
     The user's longitude coordinate when sharing location
     */
    let longitude: Double?
    
    /// Computed initials for efficient display in views
    var initials: String {
        "\(firstName.prefix(1))\(lastName.prefix(1))"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case statusText
        case statusEmoji
        case firstName
        case lastName
        case isCurrentUser
        case iconColor
        case latitude
        case longitude
    }
}
