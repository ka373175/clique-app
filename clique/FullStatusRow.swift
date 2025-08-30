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
            // Initials circle
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 50, height: 50)
                Text("\(fullStatus.firstName.prefix(1))\(fullStatus.lastName.prefix(1))")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
                Text(fullStatus.statusEmoji ?? "")
                    .font(.system(size: 16)) // Smaller size for emoji
                    .offset(x: 15, y: 15) // Adjust offset for bottom-right positioning
            }
            
            // Name + status text
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(fullStatus.firstName)
                        .font(.system(size: 30))
                    Text(fullStatus.lastName)
                        .font(.system(size: 30))
                }
                Text(fullStatus.statusText)
                    .font(.system(size: 20))
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
