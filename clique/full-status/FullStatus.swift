//
//  FullStatus.swift
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
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case statusText
        case statusEmoji
        case firstName
        case lastName
    }
}
