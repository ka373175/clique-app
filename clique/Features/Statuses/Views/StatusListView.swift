//
//  StatusListView.swift
//  clique
//
//  Created by Praveen Kumar on 8/30/25.
//

import SwiftUI

struct StatusListView: View {
    @StateObject private var viewModel = StatusViewModel()
    @State private var errorPresented = false
    
    var body: some View {
        List(viewModel.statuses) { status in
            StatusRowView(status: status)
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.fetchStatuses()
        }
        .overlay {
            if viewModel.isLoading && viewModel.statuses.isEmpty {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            if viewModel.statuses.isEmpty {
                Task { await viewModel.fetchStatuses() }
            }
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            if newValue != nil {
                errorPresented = true
            }
        }
        .alert("Error", isPresented: $errorPresented) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    StatusListView()
}
