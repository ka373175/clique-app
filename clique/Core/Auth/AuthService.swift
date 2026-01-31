//
//  AuthService.swift
//  clique
//
//  Created by Clique on 1/3/26.
//

import Foundation
import Security

/// Singleton service for managing user authentication
@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let tokenKey = "com.clique.authToken"
    private let userKey = "com.clique.currentUser"
    
    @Published private(set) var currentUser: User?
    @Published private(set) var isLoggedIn: Bool = false
    
    /// In-memory cached token to avoid repeated Keychain reads
    private var cachedToken: String?
    
    /// Flag to prevent concurrent token refresh operations
    private var isRefreshing = false
    
    private init() {
        loadStoredCredentials()
    }
    
    /// The current user's ID, extracted from stored user
    var currentUserId: String? {
        currentUser?.id
    }
    
    /// The stored JWT token (uses in-memory cache)
    var token: String? {
        if cachedToken == nil {
            cachedToken = getTokenFromKeychain()
        }
        return cachedToken
    }
    
    // MARK: - Public Methods
    
    /// Attempts to log in with the given credentials
    func login(username: String, password: String) async throws {
        let response = try await APIClient.shared.login(username: username, password: password)
        try saveCredentials(token: response.token, user: response.user)
        
        self.currentUser = response.user
        self.isLoggedIn = true
    }
    
    /// Attempts to sign up with the given information
    func signup(username: String, password: String, firstName: String, lastName: String) async throws {
        let response = try await APIClient.shared.signup(
            username: username,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        try saveCredentials(token: response.token, user: response.user)
        
        self.currentUser = response.user
        self.isLoggedIn = true
    }
    
    /// Logs out the current user
    func logout() {
        deleteTokenFromKeychain()
        deleteUserFromDefaults()
        clearAllUserCaches()
        
        self.currentUser = nil
        self.isLoggedIn = false
    }
    
    /// Refreshes the token if one exists. If refresh fails, logs out the user.
    /// Call this on app launch to ensure rolling session persistence.
    func refreshTokenIfNeeded() async {
        // Prevent concurrent refresh calls
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        
        guard let token = getTokenFromKeychain(), !token.isEmpty else {
            // No token stored, nothing to refresh
            return
        }
        
        do {
            let response = try await APIClient.shared.refreshToken(currentToken: token)
            try saveCredentials(token: response.token, user: response.user)
            self.currentUser = response.user
            self.isLoggedIn = true
            print("Token refreshed successfully")
        } catch {
            // Token is invalid or expired - log out the user
            print("Token refresh failed: \(error.localizedDescription). Logging out.")
            logout()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadStoredCredentials() {
        guard let token = getTokenFromKeychain(), !token.isEmpty else {
            isLoggedIn = false
            return
        }
        
        if let user = getUserFromDefaults() {
            currentUser = user
            isLoggedIn = true
        } else {
            // Token exists but no user data - clear everything
            logout()
        }
    }
    
    private func saveCredentials(token: String, user: User) throws {
        try saveTokenToKeychain(token)
        cachedToken = token  // Update cache
        saveUserToDefaults(user)
    }
    
    // MARK: - Keychain Operations
    
    private func saveTokenToKeychain(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw AuthError.keychainError
        }
        
        // Delete any existing token first
        deleteTokenFromKeychain()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AuthError.keychainError
        }
    }
    
    private func getTokenFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    private func deleteTokenFromKeychain() {
        cachedToken = nil  // Invalidate cache
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - UserDefaults Operations (for non-sensitive user data)
    
    private func saveUserToDefaults(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    private func getUserFromDefaults() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    private func deleteUserFromDefaults() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    /// Clears all user-specific cached data from UserDefaults
    /// This ensures that when a user logs out, the next user won't see cached data from the previous account
    private func clearAllUserCaches() {
        let cacheKeys = [
            // StatusViewModel caches
            "com.clique.cachedCurrentUserStatus",
            "com.clique.cachedFriendStatuses",
            // FriendsViewModel caches
            "com.clique.cachedFriends",
            "com.clique.cachedPendingRequests",
            "com.clique.cachedOutgoingRequests",
            // User preferences
            "com.clique.shareLocation"
        ]
        
        for key in cacheKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

/// Authentication-related errors
enum AuthError: LocalizedError {
    case keychainError
    case invalidCredentials
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .keychainError:
            return "Failed to save credentials securely"
        case .invalidCredentials:
            return "Invalid username or password"
        case .networkError:
            return "Network error occurred"
        }
    }
}
