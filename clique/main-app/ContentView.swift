//
//  ContentView.swift
//  clique
//
//  Created by Praveen Kumar on 8/13/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground // Matches light/dark mode
        appearance.shadowColor = nil // Optional: Removes the bottom separator for a cleaner look
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            NavigationStack {
                FullStatusList()
                    .navigationTitle("Statuses")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Statuses", systemImage: "list.bullet")
            }
            
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
