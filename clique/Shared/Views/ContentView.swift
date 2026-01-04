//
//  ContentView.swift
//  clique
//
//  Created by Praveen Kumar on 8/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var statusViewModel = StatusViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                StatusListView()
                    .navigationTitle("Statuses")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Statuses", systemImage: "list.bullet")
            }
            
            AddUserView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environmentObject(statusViewModel)
    }
}

#Preview {
    ContentView()
}

