//
//  ProfileView.swift
//  clique
//
//  Created by Praveen Kumar on 9/15/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: StatusViewModel
    @ObservedObject private var authService = AuthService.shared
    @State private var statusEmoji: String = ""
    @State private var statusText: String = ""
    @State private var lastKnownEmoji: String?
    @State private var lastKnownText: String?
    @FocusState private var isTextEditorFocused: Bool
    @State private var isEmojiFieldFocused: Bool = false

    private func userInitials(for user: User) -> String {
        String(user.firstName.prefix(1)).uppercased()
            + String(user.lastName.prefix(1)).uppercased()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // User Profile Section
                if let user = authService.currentUser {
                    VStack(spacing: 12) {
                        // Avatar
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 80, height: 80)
                            .overlay {
                                Text(userInitials(for: user))
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }

                        // User Details
                        VStack(spacing: 4) {
                            Text(user.fullName)
                                .font(.title2)
                                .fontWeight(.semibold)

                            Text("@\(user.username)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 16)
                }

                Spacer()

                // Emoji Input
                VStack(spacing: 8) {
                    ZStack(alignment: .topTrailing) {
                        EmojiTextField(
                            text: $statusEmoji,
                            isFocused: $isEmojiFieldFocused,
                            placeholder: "+"
                        )
                        .frame(width: 100, height: 100)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )

                        // Clear button - only show when emoji is selected
                        if !statusEmoji.isEmpty {
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    statusEmoji = ""
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(
                                        .white,
                                        Color(.systemGray3)
                                    )
                            }
                            .offset(x: 4, y: -4)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(
                        .easeInOut(duration: 0.15),
                        value: statusEmoji.isEmpty
                    )

                    Text(
                        statusEmoji.isEmpty
                            ? "Tap to add emoji" : "Tap to change"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                // Status Text Input
                ZStack(alignment: .top) {
                    // Placeholder
                    if statusText.isEmpty {
                        Text("What's on your mind?")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.top, 16)
                    }

                    // Expanding TextEditor
                    TextEditor(text: $statusText)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 60)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .focused($isTextEditorFocused)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal, 24)

                Spacer()


            }
            .contentShape(Rectangle())
            .onTapGesture {
                isTextEditorFocused = false
                isEmojiFieldFocused = false
                fireAndForgetUpdateStatus()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isTextEditorFocused {
                        Button(action: {
                            isTextEditorFocused = false
                            fireAndForgetUpdateStatus()
                        }) {
                            Text("Update")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .controlSize(.large)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isTextEditorFocused)
            .onChange(of: viewModel.currentUserStatus) { _, _ in
                prefillCurrentStatus()
            }
            .onChange(of: statusEmoji) { _, _ in
                // Fire and forget when emoji changes
                fireAndForgetUpdateStatus()
            }
            .task {
                // Fetch statuses if not already loaded (handles direct navigation to ProfileView)
                if viewModel.currentUserStatus == nil && !viewModel.isLoading {
                    await viewModel.fetchStatuses()
                }
                prefillCurrentStatus()
            }

        }
    }

    // MARK: - Private Methods

    private func prefillCurrentStatus() {
        guard let currentStatus = viewModel.currentUserStatus else { return }
        
        // Only prefill if user hasn't started editing (fields still match last known status or are empty)
        let hasUserEditedEmoji = !statusEmoji.isEmpty && statusEmoji != (lastKnownEmoji ?? "")
        let hasUserEditedText = !statusText.isEmpty && statusText != (lastKnownText ?? "")
        
        if !hasUserEditedEmoji {
            statusEmoji = currentStatus.statusEmoji ?? ""
        }
        if !hasUserEditedText {
            statusText = currentStatus.statusText
        }
        
        // Track what we prefilled so we can detect user edits
        lastKnownEmoji = currentStatus.statusEmoji ?? ""
        lastKnownText = currentStatus.statusText
    }

    private func fireAndForgetUpdateStatus() {
        // Only update if values have changed from last known server values
        let emojiChanged = statusEmoji != (lastKnownEmoji ?? "")
        let textChanged = statusText != (lastKnownText ?? "")
        
        guard emojiChanged || textChanged else {
            return // No changes to send
        }
        
        // Update last known values to current values
        lastKnownEmoji = statusEmoji
        lastKnownText = statusText
        
        // Fire and forget - don't wait for response
        Task {
            try? await APIClient.shared.updateStatus(
                emoji: statusEmoji,
                text: statusText
            )
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(StatusViewModel())
}
