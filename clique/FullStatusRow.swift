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
        HStack {
            Image(systemName: "person.circle.fill").foregroundColor(.blue).font(.system(size: 40))
            Text(fullStatus.statusEmoji)
            VStack(alignment: .leading) {
                HStack {
                    Text(fullStatus.firstName).font(.system(size: 30))
                    Text(fullStatus.lastName).font(.system(size: 30))
                }
                Text(fullStatus.statusText).font(.system(size: 20))
            }
            
        }
    }
}

#Preview {
    FullStatusRow(fullStatus: fullStatuses[0])
}
