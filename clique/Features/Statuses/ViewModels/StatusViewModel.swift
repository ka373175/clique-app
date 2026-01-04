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
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchStatuses() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            statuses = try await APIClient.shared.fetchStatuses()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
