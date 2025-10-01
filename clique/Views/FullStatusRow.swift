//
//  FullStatusRow.swift
//  clique
//
//  Created by Praveen Kumar on 8/19/25.
//

import SwiftUI

struct FullStatusRow: View {
    let fullStatus: FullStatus

    private var initials: String {
        let first = fullStatus.firstName.first.map(String.init) ?? ""
        let last = fullStatus.lastName.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 50, height: 50)
                Text(initials)
                    .foregroundColor(.primary)
                    .font(.system(size: 18, weight: .semibold))
                    .accessibilityHidden(true)
            }
            .overlay(alignment: .bottomTrailing) {
                if let emoji = fullStatus.statusEmoji, !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: 14))
                        .padding(2)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .offset(x: 6, y: 6)
                        .accessibilityLabel("Status emoji")
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(fullStatus.firstName) \(fullStatus.lastName)")
                    .font(.system(size: 18, weight: .medium))
                    .lineLimit(1)

                Text(fullStatus.statusText)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    FullStatusRow(fullStatus: fullStatusesForTesting[0])
}
