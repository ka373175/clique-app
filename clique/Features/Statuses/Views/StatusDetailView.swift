//
//  StatusDetailView.swift
//  clique
//
//  Created by Praveen Kumar on 8/30/25.
//

import SwiftUI

struct StatusDetailView: View {
    let status: FullStatus
    
    var body: some View {
        VStack(spacing: 24) {
            // Large emoji circle (similar to StatusRowView but bigger)
            ZStack {
                Circle()
                    .fill(IconColor.from(status.iconColor).color.gradient)
                    .frame(width: 120, height: 120)
                Text(status.initials)
                    .foregroundColor(.white)
                    .font(.system(size: 48, weight: .bold))
                Text(status.statusEmoji ?? "")
                    .font(.system(size: 36))
                    .offset(x: 40, y: 38)
            }
            
            // Username
            Text("\(status.firstName) \(status.lastName)")
                .font(.title)
                .fontWeight(.semibold)
            
            // Status text
            Text(status.statusText.isEmpty ? "No status yet" : status.statusText)
                .font(.title3)
                .foregroundStyle(status.statusText.isEmpty ? .tertiary : .secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 40)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StatusDetailView(status: statusesForTesting[0])
    }
}
