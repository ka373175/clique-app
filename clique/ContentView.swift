//
//  ContentView.swift
//  clique
//
//  Created by Praveen Kumar on 8/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
        VStack {
            FullStatusRow(fullStatus: fullStatuses[0])
            FullStatusRow(fullStatus: fullStatuses[1])
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
