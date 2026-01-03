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
                        .font(.system(size: 24))
                    
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
        
        do {
            try await APIClient.shared.updateStatus(
                emoji: statusEmoji,
                text: statusText
            )
            successMessage = "Status updated successfully!"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    SetStatusView()
}
