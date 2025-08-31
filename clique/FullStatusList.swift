//
//  FullStatusList.swift
//  clique
//
//  Created by Praveen Kumar on 8/30/25.
//

import SwiftUI

struct FullStatusList: View {
    var body: some View {
        List(fullStatuses) {
            fullStatus in FullStatusRow(fullStatus: fullStatus)
        }
        .listStyle(.plain) // Remove default list styling and margins
    }
}

#Preview {
    FullStatusList()
}
