//
//  AddUserView.swift
//  clique
//
//  Created by Praveen Kumar on 9/15/25.
//

import SwiftUI

struct AddUserView: View {
    @State private var username: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Add User")) {
                    TextField("Username", text: $username)
                }
                
                if isLoading {
                    ProgressView("Adding...")
                } else {
                    Button("Add User") {
                        Task {
                            await addUser()
                        }
                    }
                    .disabled(username.isEmpty)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }
                
                if let success = successMessage {
                    Text(success)
                        .foregroundStyle(.green)
                }
            }
            .navigationTitle("Add User by Username")
        }
    }
    
    private func addUser() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await APIClient.shared.addUser(username: username)
            successMessage = "User added successfully!"
            username = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    AddUserView()
}
