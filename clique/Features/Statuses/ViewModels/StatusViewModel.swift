//
//  StatusViewModel.swift
//  clique
//
//  Created by Praveen Kumar on 8/30/25.
//

import SwiftUI

@MainActor
class StatusViewModel: ObservableObject {
    private let currentUserStatusKey = "com.clique.cachedCurrentUserStatus"
    private let friendStatusesKey = "com.clique.cachedFriendStatuses"
    
    /// Active fetch task to enable cancellation and prevent duplicate fetches
    private var activeFetchTask: Task<Void, Never>?
    
    @Published var statuses: [FullStatus] = []
    @Published var currentUserStatus: FullStatus?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadCachedStatuses()
    }
    
    func fetchStatuses() async {
        // Cancel any existing fetch to prevent race conditions
        activeFetchTask?.cancel()
        
        let task = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }
            
            do {
                let allStatuses = try await APIClient.shared.fetchStatuses()
                
                // Check for cancellation before updating state
                guard !Task.isCancelled else { return }
                
                // Separate current user's status from friends' statuses
                currentUserStatus = allStatuses.first { $0.isCurrentUser }
                statuses = allStatuses.filter { !$0.isCurrentUser }
                
                // Cache the fetched data
                saveCachedStatuses()
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
            }
        }
        
        activeFetchTask = task
        await task.value
    }
    
    // MARK: - Cache Operations
    
    private func loadCachedStatuses() {
        // Load cached current user status
        if let data = UserDefaults.standard.data(forKey: currentUserStatusKey),
           let cached = try? JSONDecoder().decode(FullStatus.self, from: data) {
            currentUserStatus = cached
        }
        
        // Load cached friend statuses
        if let data = UserDefaults.standard.data(forKey: friendStatusesKey),
           let cached = try? JSONDecoder().decode([FullStatus].self, from: data) {
            statuses = cached
        }
    }
    
    private func saveCachedStatuses() {
        // Save current user status
        if let status = currentUserStatus,
           let encoded = try? JSONEncoder().encode(status) {
            UserDefaults.standard.set(encoded, forKey: currentUserStatusKey)
        }
        
        // Save friend statuses
        if let encoded = try? JSONEncoder().encode(statuses) {
            UserDefaults.standard.set(encoded, forKey: friendStatusesKey)
        }
    }
    
    /// Optimistically update the current user's status in memory and cache
    /// Call this after the user updates their status to keep the cache in sync
    func updateCurrentUserStatusOptimistically(emoji: String, text: String) {
        guard let current = currentUserStatus else { return }
        
        // Create a new FullStatus with updated values
        currentUserStatus = FullStatus(
            id: current.id,
            statusText: text,
            statusEmoji: emoji.isEmpty ? nil : emoji,
            firstName: current.firstName,
            lastName: current.lastName,
            isCurrentUser: current.isCurrentUser,
            iconColor: current.iconColor,
            latitude: current.latitude,
            longitude: current.longitude
        )
        
        // Update the cache immediately
        saveCachedStatuses()
    }
    
    /// Optimistically update the current user's icon color in memory and cache
    func updateCurrentUserIconColorOptimistically(_ iconColor: String) {
        guard let current = currentUserStatus else { return }
        
        currentUserStatus = FullStatus(
            id: current.id,
            statusText: current.statusText,
            statusEmoji: current.statusEmoji,
            firstName: current.firstName,
            lastName: current.lastName,
            isCurrentUser: current.isCurrentUser,
            iconColor: iconColor,
            latitude: current.latitude,
            longitude: current.longitude
        )
        
        saveCachedStatuses()
    }
}
