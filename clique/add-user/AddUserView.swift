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
        
        guard let url = URL(string: "https://60q4fmxnb7.execute-api.us-east-2.amazonaws.com/prod/add-user") else { // Replace with your actual API endpoint for adding user
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "username": username
            // Add any other required fields if needed
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                successMessage = "User added successfully!"
                username = "" // Clear the field
            } else {
                errorMessage = "Failed to add user"
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    AddUserView()
}
