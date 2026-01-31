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
    @AppStorage("com.clique.shareLocation") private var shareLocation = false
    @State private var showingLocationError = false
    @State private var locationErrorMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Location Sharing Section
                Section {
                    Toggle(isOn: $shareLocation) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Share Location")
                            Text("Share your location with friends when you update your status")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Privacy")
                }
                .onChange(of: shareLocation) { _, newValue in
                    if newValue {
                        // When toggled on, request location and update immediately
                        Task {
                            await handleLocationToggleOn()
                        }
                    } else {
                        // When toggled off, clear location from server
                        Task {
                            await handleLocationToggleOff()
                        }
                    }
                }
                
                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
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
            .alert("Location Error", isPresented: $showingLocationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(locationErrorMessage)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleLocationToggleOn() async {
        do {
            let coordinate = try await LocationManager.shared.getCurrentLocation()
            // Fire and forget - don't wait for API response
            Task {
                try? await APIClient.shared.updateLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        } catch {
            // If location fails, turn the toggle back off
            shareLocation = false
            locationErrorMessage = error.localizedDescription
            showingLocationError = true
        }
    }
    
    private func handleLocationToggleOff() async {
        // Fire and forget - clear location from server
        Task {
            try? await APIClient.shared.clearLocation()
        }
    }
}

#Preview {
    SettingsView()
}
