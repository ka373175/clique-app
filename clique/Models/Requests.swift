//
//  Requests.swift
//  clique
//
//  Created by Praveen Kumar on 9/30/25.
//

import Foundation

struct AddUserRequest: Encodable {
    let username: String
}

struct UpdateStatusRequest: Encodable {
    let statusEmoji: String?
    let statusText: String
}
