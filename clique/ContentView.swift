//
//  ContentView.swift
//  clique
//
//  Created by Praveen Kumar on 8/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FullStatusList().tabItem{Label("Statuses", systemImage: "list.bullet")}
            SetStatusView()
                .tabItem {
                    Label("Set Status", systemImage: "pencil")
                }
            AddUserView()
                .tabItem {
                    Label("Add User", systemImage: "person.badge.plus")
                }
        }
    }
}

#Preview {
    ContentView()
}
