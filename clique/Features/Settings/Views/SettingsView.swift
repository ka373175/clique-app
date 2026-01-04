//
//  SettingsView.swift
//  clique
//
//  Created by Clique on 1/3/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // User Info Section
                Section {
                    if let user = authService.currentUser {
                        HStack(spacing: 16) {
                            // Avatar
                            Circle()
                                .fill(Color.blue.gradient)
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Text(user.firstName.prefix(1).uppercased() + user.lastName.prefix(1).uppercased())
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                }
                            
                            // User Details
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullName)
                                    .font(.headline)
                                
                                Text("@\(user.username)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("Account")
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
