//
//  AuthView.swift
//  clique
//
//  Created by Clique on 1/3/26.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject private var authService = AuthService.shared
    
    @State private var isLoginMode = false
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Logo/Header
                    VStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue)
                        
                        Text("Clique")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(isLoginMode ? "Welcome back!" : "Create your account")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 16) {
                        if !isLoginMode {
                            HStack(spacing: 12) {
                                TextField("First Name", text: $firstName)
                                    .textFieldStyle(.roundedBorder)
                                    .textContentType(.givenName)
                                    .autocapitalization(.words)
                                
                                TextField("Last Name", text: $lastName)
                                    .textFieldStyle(.roundedBorder)
                                    .textContentType(.familyName)
                                    .autocapitalization(.words)
                            }
                        }
                        
                        TextField("Username", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(isLoginMode ? .password : .newPassword)
                        
                        if !isLoginMode {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.newPassword)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error Message
                    if let error = errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Submit Button
                    Button {
                        Task {
                            await submit()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(isLoginMode ? "Log In" : "Sign Up")
                                .fontWeight(.semibold)
                            
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid && !isLoading ? Color.blue : Color.gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    .disabled(!isFormValid || isLoading)
                    .animation(.easeInOut(duration: 0.2), value: isLoading)
                    
                    // Toggle Mode
                    Button {
                        withAnimation {
                            isLoginMode.toggle()
                            errorMessage = nil
                        }
                    } label: {
                        Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Log In")
                            .font(.footnote)
                            .foregroundStyle(.blue)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var isFormValid: Bool {
        if isLoginMode {
            return !username.isEmpty && !password.isEmpty
        } else {
            return !username.isEmpty && 
                   !password.isEmpty && 
                   !firstName.isEmpty && 
                   !lastName.isEmpty &&
                   password == confirmPassword &&
                   password.count >= 6
        }
    }
    
    private func submit() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if isLoginMode {
                try await authService.login(username: username, password: password)
            } else {
                // Validate passwords match
                guard password == confirmPassword else {
                    errorMessage = "Passwords do not match"
                    isLoading = false
                    return
                }
                
                guard password.count >= 6 else {
                    errorMessage = "Password must be at least 6 characters"
                    isLoading = false
                    return
                }
                
                try await authService.signup(
                    username: username,
                    password: password,
                    firstName: firstName,
                    lastName: lastName
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    AuthView()
}
