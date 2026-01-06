//
//  FriendsViewModel.swift
//  clique
//
//  Created by Clique on 1/4/26.
//

import SwiftUI

@MainActor
class FriendsViewModel: ObservableObject {
    private let friendsCacheKey = "com.clique.cachedFriends"
    
    /// Tracks friend IDs currently being modified to prevent fetch from overwriting
    private var pendingMutations: Set<String> = []
    
    @Published var friends: [Friend] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadCachedFriends()
    }
    
    /// Fetches the friends list from the API
    /// Skips fetch if there are pending mutations to avoid overwriting optimistic updates
    func fetchFriends() async {
        guard pendingMutations.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            friends = try await APIClient.shared.fetchFriends()
            saveCachedFriends()
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
            saveCachedFriends()
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
            saveCachedFriends()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Removes a friend optimistically (fire-and-forget)
    /// Immediately removes from UI and fires API call in background
    func removeFriendOptimistically(_ friend: Friend) {
        // Store the original index in case we need to restore
        guard let index = friends.firstIndex(where: { $0.id == friend.id }) else { return }
        
        // Track this mutation to prevent concurrent fetch from overwriting
        pendingMutations.insert(friend.id)
        
        // Immediately remove from UI for instant feedback
        friends.remove(at: index)
        saveCachedFriends()
        
        // Fire API call in background
        Task {
            defer { pendingMutations.remove(friend.id) }
            
            do {
                try await APIClient.shared.removeFriend(friendId: friend.id)
            } catch {
                // If API call fails, restore the friend at a safe index and show error
                let safeIndex = min(index, friends.count)
                friends.insert(friend, at: safeIndex)
                saveCachedFriends()
                errorMessage = "Failed to remove friend: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Cache Operations
    
    private func loadCachedFriends() {
        if let data = UserDefaults.standard.data(forKey: friendsCacheKey),
           let cached = try? JSONDecoder().decode([Friend].self, from: data) {
            friends = cached
        }
    }
    
    private func saveCachedFriends() {
        if let encoded = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(encoded, forKey: friendsCacheKey)
        }
    }
}
