//
//  StatusViewModel.swift
//  clique
//
//  Created by Praveen Kumar on 9/30/25.
//

import Foundation
import SwiftUI

@MainActor
final class StatusViewModel: ObservableObject {
    @Published var fullStatuses: [FullStatus] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingError: Bool = false
    
    func fetchStatuses() async {
        isLoading = true
        errorMessage = nil
        do {
            let statuses: [FullStatus] = try await APIClient.shared.get("statuses")
            self.fullStatuses = statuses
        } catch {
            if let apiError = error as? APIError {
                self.errorMessage = apiError.errorDescription
            } else {
                self.errorMessage = error.localizedDescription
            }
            self.showingError = true
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
}
