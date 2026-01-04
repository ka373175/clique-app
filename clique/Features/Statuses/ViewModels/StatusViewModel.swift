//
//  StatusViewModel.swift
//  clique
//
//  Created by Praveen Kumar on 8/30/25.
//

import SwiftUI

@MainActor
class StatusViewModel: ObservableObject {
    @Published var statuses: [FullStatus] = []
    @Published var currentUserStatus: FullStatus?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchStatuses() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let allStatuses = try await APIClient.shared.fetchStatuses()
            // Separate current user's status from friends' statuses
            currentUserStatus = allStatuses.first { $0.isCurrentUser }
            statuses = allStatuses.filter { !$0.isCurrentUser }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
