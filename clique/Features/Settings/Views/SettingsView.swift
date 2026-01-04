//
//  SettingsView.swift
//  clique
//
//  Created by Clique on 1/3/26.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var authService = AuthService.shared
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                
                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppConfig.version)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
                
                // Actions Section
                Section {
                    Button(role: .destructive) {
                        showingLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    authService.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

#Preview {
    SettingsView()
}
