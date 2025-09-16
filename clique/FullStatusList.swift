//
//  FullStatusList.swift
//  clique
//
//  Created by Praveen Kumar on 8/30/25.
//

import SwiftUI

struct FullStatusList: View {
    @StateObject private var viewModel = StatusViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(viewModel.fullStatuses) { fullStatus in
                    FullStatusRow(fullStatus: fullStatus)
                }
                .listStyle(.plain)
            }
        }
        .task {
            await viewModel.fetchStatuses()
        }
    }
}

#Preview {
    FullStatusList()
}
