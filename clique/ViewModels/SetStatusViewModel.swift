//
//  SetStatusViewModel.swift
//  clique
//
//  Created by Praveen Kumar on 9/30/25.
//

import Foundation

@MainActor
final class SetStatusViewModel: ObservableObject {
    @Published var statusEmoji: String = ""
    @Published var statusText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    func updateStatus() async {
        guard !statusText.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Status text cannot be empty."
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        let body = UpdateStatusRequest(statusEmoji: statusEmoji.isEmpty ? nil : statusEmoji, statusText: statusText)
        let path = "update-status/\(API.currentUserId)"

        do {
            try await APIClient.shared.post(path, body: body)
            successMessage = "Status updated successfully!"
            // optionally clear or keep fields
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
}
