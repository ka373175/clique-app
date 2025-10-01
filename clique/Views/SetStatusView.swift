//
//  SetStatusView.swift
//  clique
//
//  Created by Praveen Kumar on 9/15/25.
//

import SwiftUI

struct SetStatusView: View {
    @StateObject private var viewModel = SetStatusViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Your Status")) {
                    TextField("Status Emoji (optional)", text: $viewModel.statusEmoji)
                        .font(.system(size: 24))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    TextField("Status Text", text: $viewModel.statusText)
                }

                Section {
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Updating…")
                            Spacer()
                        }
                    } else {
                        Button("Update Status") {
                            Task { await viewModel.updateStatus() }
                        }
                        .disabled(viewModel.statusText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }

                    if let success = viewModel.successMessage {
                        Text(success)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Set Your Status")
        }
    }
}

#Preview {
    SetStatusView()
}
