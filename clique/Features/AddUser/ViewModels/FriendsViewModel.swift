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
    private let pendingRequestsCacheKey = "com.clique.cachedPendingRequests"
    private let outgoingRequestsCacheKey = "com.clique.cachedOutgoingRequests"
    
    /// Tracks friend IDs currently being modified to prevent fetch from overwriting
    private var pendingMutations: Set<String> = []
    /// Tracks request IDs currently being processed
    private var pendingRequestMutations: Set<String> = []
    
    @Published var friends: [Friend] = []
    @Published var pendingRequests: [FriendRequest] = []
    @Published var outgoingRequests: [OutgoingFriendRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadCachedFriends()
        loadCachedPendingRequests()
        loadCachedOutgoingRequests()
    }
    
    /// Fetches the friends list from the API
    /// Skips fetch if there are pending mutations to avoid overwriting optimistic updates
    func fetchFriends() async {
        guard pendingMutations.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            async let friendsResult = APIClient.shared.fetchFriends()
            async let requestsResult = APIClient.shared.fetchPendingFriendRequests()
            async let outgoingResult = APIClient.shared.fetchOutgoingFriendRequests()
            
            let (fetchedFriends, fetchedRequests, fetchedOutgoing) = try await (friendsResult, requestsResult, outgoingResult)
            
            friends = fetchedFriends
            saveCachedFriends()
            
            // Only update pending requests if no pending mutations
            if pendingRequestMutations.isEmpty {
                pendingRequests = fetchedRequests
                saveCachedPendingRequests()
            }
            
            outgoingRequests = fetchedOutgoing
            saveCachedOutgoingRequests()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Fetches only pending friend requests
    func fetchPendingRequests() async {
        guard pendingRequestMutations.isEmpty else { return }
        
        do {
            pendingRequests = try await APIClient.shared.fetchPendingFriendRequests()
            saveCachedPendingRequests()
        } catch {
            // Silently fail - pending requests are supplementary
            print("Failed to fetch pending requests: \(error.localizedDescription)")
        }
    }
    
    /// Sends a friend request by username
    /// - Returns: True if successful, false otherwise
    /// Sends a friend request by username
    /// - Throws: Error if the request fails
    func addFriend(username: String) async throws {
        // Send the request and get the friend details back
        let friend = try await APIClient.shared.addFriend(username: username)
        
        // Add to outgoing requests for immediate UI update
        let outgoingRequest = OutgoingFriendRequest(
            id: UUID().uuidString, // Temporary ID until next refresh
            recipientId: friend.id,
            username: friend.username,
            firstName: friend.firstName,
            lastName: friend.lastName
        )
        outgoingRequests.append(outgoingRequest)
        saveCachedOutgoingRequests()
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
        Task { [weak self] in
            guard let self else { return }
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
    
    /// Approves a friend request optimistically (fire-and-forget)
    /// Immediately removes from pending list and adds to friends, fires API in background
    func approveFriendRequestOptimistically(_ request: FriendRequest) {
        guard let index = pendingRequests.firstIndex(where: { $0.id == request.id }) else { return }
        
        // Track this mutation
        pendingRequestMutations.insert(request.id)
        
        // Optimistically remove from pending and add to friends
        pendingRequests.remove(at: index)
        let newFriend = Friend(
            id: request.requesterId,
            username: request.username,
            firstName: request.firstName,
            lastName: request.lastName
        )
        friends.append(newFriend)
        saveCachedPendingRequests()
        saveCachedFriends()
        
        // Fire API call in background
        Task { [weak self] in
            guard let self else { return }
            defer { pendingRequestMutations.remove(request.id) }
            
            do {
                try await APIClient.shared.approveFriendRequest(friendshipId: request.id)
            } catch {
                // If API call fails, restore the pending request and remove the friend
                let safeIndex = min(index, pendingRequests.count)
                pendingRequests.insert(request, at: safeIndex)
                friends.removeAll { $0.id == newFriend.id }
                saveCachedPendingRequests()
                saveCachedFriends()
                errorMessage = "Failed to approve friend request: \(error.localizedDescription)"
            }
        }
    }
    
    /// Denies a friend request optimistically (fire-and-forget)
    /// Immediately removes from pending list, fires API in background
    func denyFriendRequestOptimistically(_ request: FriendRequest) {
        guard let index = pendingRequests.firstIndex(where: { $0.id == request.id }) else { return }
        
        // Track this mutation
        pendingRequestMutations.insert(request.id)
        
        // Optimistically remove from pending
        pendingRequests.remove(at: index)
        saveCachedPendingRequests()
        
        // Fire API call in background
        Task { [weak self] in
            guard let self else { return }
            defer { pendingRequestMutations.remove(request.id) }
            
            do {
                try await APIClient.shared.denyFriendRequest(friendshipId: request.id)
            } catch {
                // If API call fails, restore the pending request
                let safeIndex = min(index, pendingRequests.count)
                pendingRequests.insert(request, at: safeIndex)
                saveCachedPendingRequests()
                errorMessage = "Failed to deny friend request: \(error.localizedDescription)"
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
    
    private func loadCachedPendingRequests() {
        if let data = UserDefaults.standard.data(forKey: pendingRequestsCacheKey),
           let cached = try? JSONDecoder().decode([FriendRequest].self, from: data) {
            pendingRequests = cached
        }
    }
    
    private func saveCachedPendingRequests() {
        if let encoded = try? JSONEncoder().encode(pendingRequests) {
            UserDefaults.standard.set(encoded, forKey: pendingRequestsCacheKey)
        }
    }
    
    private func loadCachedOutgoingRequests() {
        if let data = UserDefaults.standard.data(forKey: outgoingRequestsCacheKey),
           let cached = try? JSONDecoder().decode([OutgoingFriendRequest].self, from: data) {
            outgoingRequests = cached
        }
    }
    
    private func saveCachedOutgoingRequests() {
        if let encoded = try? JSONEncoder().encode(outgoingRequests) {
            UserDefaults.standard.set(encoded, forKey: outgoingRequestsCacheKey)
        }
    }
}
