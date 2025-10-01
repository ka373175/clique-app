//
//  AddUserView.swift
//  clique
//
//  Created by Praveen Kumar on 9/15/25.
//

import SwiftUI

import SwiftUI

struct AddUserView: View {
    @StateObject private var viewModel = AddUserViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Add User")) {
                    TextField("Username", text: $viewModel.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                Section {
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Adding…")
                            Spacer()
                        }
                    } else {
                        Button(action: {
                            Task { await viewModel.addUser() }
                        }, label: {
                            Text("Add User")
                                .frame(maxWidth: .infinity, alignment: .center)
                        })
                        .disabled(viewModel.username.trimmingCharacters(in: .whitespaces).isEmpty)
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
            .navigationTitle("Add User")
        }
    }
}

#Preview {
    AddUserView()
}
