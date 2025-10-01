//
//  FullStatusList.swift
//  clique
//
//  Created by Praveen Kumar on 8/30/25.
//

import SwiftUI

struct FullStatusList: View {
    @StateObject private var viewModel = StatusViewModel()
    @State private var showErrorAlert = false

    var body: some View {
        List(viewModel.fullStatuses) { fullStatus in
            FullStatusRow(fullStatus: fullStatus)
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.fetchStatuses()
        }
        .overlay {
            if viewModel.isLoading && viewModel.fullStatuses.isEmpty {
                ProgressView("Loading...")
            }
        }
        .task {
            if viewModel.fullStatuses.isEmpty {
                await viewModel.fetchStatuses()
            }
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            showErrorAlert = newValue != nil
        }
        .alert("Error", isPresented: $showErrorAlert, actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
}

#Preview {
    FullStatusList()
}
