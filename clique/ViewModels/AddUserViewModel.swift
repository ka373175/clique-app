//
//  AddUserViewModel.swift
//  clique
//
//  Created by Praveen Kumar on 9/30/25.
//

import Foundation

@MainActor
final class AddUserViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    func addUser() async {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.errorMessage = "Username cannot be empty."
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        let request = AddUserRequest(username: username)
        do {
            try await APIClient.shared.post("add-user", body: request)
            successMessage = "User added successfully!"
            username = ""
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
}
