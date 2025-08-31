//
//  FullStatusRow.swift
//  clique
//
//  Created by Praveen Kumar on 8/19/25.
//

import SwiftUI

struct FullStatusRow: View {
    var fullStatus: FullStatus
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // ZStack: circle + emoji
            ZStack {
                // Person icon
                Circle()
                    .fill(Color.black)
                    .frame(width: 50, height: 50)
                // Initials
                Text("\(fullStatus.firstName.prefix(1))\(fullStatus.lastName.prefix(1))")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
                // Status emoji
                Text(fullStatus.statusEmoji ?? "")
                    .font(.system(size: 14)) // Smaller size for emoji
                    .offset(x: 16, y: 15) // Adjust offset for bottom-right positioning
            }
            
            // VStack: Name + status text
            VStack(alignment: .leading, spacing: 4) {
                // HStack: Name
                HStack {
                    Text("\(fullStatus.firstName) \(fullStatus.lastName)")
                        .font(.system(size: 20))
                        .lineLimit(1)
                }
                // Status text
                Text(fullStatus.statusText)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

#Preview {
    FullStatusRow(fullStatus: fullStatuses[0])
}
