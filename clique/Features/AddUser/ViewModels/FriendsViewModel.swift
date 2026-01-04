//
//  FriendsViewModel.swift
//  clique
//
//  Created by Clique on 1/4/26.
//

import SwiftUI

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    /// Fetches the friends list from the API
    func fetchFriends() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            friends = try await APIClient.shared.fetchFriends()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Adds a friend by username
    /// - Returns: True if successful, false otherwise
    func addFriend(username: String) async -> Bool {
        errorMessage = nil
        
        do {
            let newFriend = try await APIClient.shared.addFriend(username: username)
            friends.append(newFriend)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Removes a friend from the list
    /// - Returns: True if successful, false otherwise
    func removeFriend(_ friend: Friend) async -> Bool {
        errorMessage = nil
        
        do {
            try await APIClient.shared.removeFriend(friendId: friend.id)
            friends.removeAll { $0.id == friend.id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
