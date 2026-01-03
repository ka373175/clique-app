//
//  CliqueApp.swift
//  clique
//
//  Created by Praveen Kumar on 8/13/25.
//

import SwiftUI

@main
struct CliqueApp: App {
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            if authService.isLoggedIn {
                ContentView()
            } else {
                AuthView()
            }
        }
    }
}
