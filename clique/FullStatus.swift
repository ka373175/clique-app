//
//  FullStatus.swift
//  clique
//
//  Created by Praveen Kumar on 8/13/25.
//

import Foundation

struct FullStatus: Codable, Hashable, Identifiable {
    /*
     id: int
     Identifier for swift to conform to Identifiable protocol
     */
    var id: Int
    
    /*
     statusText: string
     The status of the user
     */
    var statusText: String
    
    /*
     statusEmoji: string?
     The emoji for the user's status
     */
    var statusEmoji: String?
    
    /*
     firstName: string
     The first name of the user
     */
    var firstName: String
    
    /*
     lastName: string
     The last name of the user
     */
    var lastName: String
}
