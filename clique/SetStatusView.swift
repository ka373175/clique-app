//
//  SetStatusView.swift
//  clique
//
//  Created by Praveen Kumar on 9/15/25.
//

import SwiftUI

struct SetStatusView: View {
    @State private var statusEmoji: String = ""
    @State private var statusText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Your Status")) {
                    TextField("Status Emoji (optional)", text: $statusEmoji)
                        .font(.system(size: 24)) // Larger for emoji input
                    
                    TextField("Status Text", text: $statusText)
                }
                
                if isLoading {
                    ProgressView("Updating...")
                } else {
                    Button("Update Status") {
                        Task {
                            await updateStatus()
                        }
                    }
                    .disabled(statusText.isEmpty)
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
            .navigationTitle("Set Your Status")
        }
    }
    
    private func updateStatus() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        guard let url = URL(string: "https://60q4fmxnb7.execute-api.us-east-2.amazonaws.com/prod/update-status") else { // Replace with your actual API endpoint for updating status
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "statusEmoji": statusEmoji,
            "statusText": statusText
            // Add any other required fields, like user ID if needed
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                successMessage = "Status updated successfully!"
            } else {
                errorMessage = "Failed to update status"
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    SetStatusView()
}
