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
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccess: Bool = false
    @State private var lastKnownEmoji: String?
    @State private var lastKnownText: String?
    @State private var successDismissTask: Task<Void, Never>?
    @FocusState private var isTextEditorFocused: Bool
    @State private var isEmojiFieldFocused: Bool = false

    // MARK: - Computed Properties

    private var canUpdateStatus: Bool {
        !statusText.isEmpty && !isLoading
    }

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

                // Feedback Messages
                if let error = errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }

                if showSuccess {
                    Label("Updated!", systemImage: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.green)
                        .transition(.opacity)
                }

                // Update Button
                Button {
                    // Guard against rapid taps before Task spawns
                    guard !isLoading else { return }
                    isLoading = true
                    Task {
                        await updateStatus()
                    }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Update Status")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        canUpdateStatus
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        Color.blue, Color.blue.opacity(0.8),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(Color.gray.opacity(0.5))
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(
                        color: canUpdateStatus ? .blue.opacity(0.3) : .clear,
                        radius: 8,
                        y: 4
                    )
                }
                .disabled(!canUpdateStatus)
                .opacity(canUpdateStatus ? 1.0 : 0.6)
                .scaleEffect(canUpdateStatus ? 1.0 : 0.98)
                .animation(.easeInOut(duration: 0.2), value: canUpdateStatus)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .contentShape(RoundedRectangle(cornerRadius: 16))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isTextEditorFocused = false
                isEmojiFieldFocused = false
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isTextEditorFocused || isEmojiFieldFocused {
                        Button(action: {
                            isTextEditorFocused = false
                            isEmojiFieldFocused = false
                        }) {
                            Image(systemName: "checkmark")
                        }
                        .buttonStyle(.borderedProminent) // 1. Applies the standard filled style
                        .tint(.blue)                     // 2. Sets the fill color to blue
                        .controlSize(.large)             // 3. (Optional) Adjusts the button size
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: errorMessage)
            .animation(.easeInOut(duration: 0.2), value: showSuccess)
            .animation(.easeInOut(duration: 0.2), value: isTextEditorFocused)
            .onChange(of: viewModel.currentUserStatus) { _, _ in
                prefillCurrentStatus()
            }
            .task {
                // Fetch statuses if not already loaded (handles direct navigation to ProfileView)
                if viewModel.currentUserStatus == nil && !viewModel.isLoading {
                    await viewModel.fetchStatuses()
                }
                prefillCurrentStatus()
            }
            .onDisappear {
                successDismissTask?.cancel()
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

    private func updateStatus() async {
        // Note: isLoading is set to true before this Task is spawned to prevent race conditions
        errorMessage = nil
        showSuccess = false

        do {
            try await APIClient.shared.updateStatus(
                emoji: statusEmoji,
                text: statusText
            )
            showSuccess = true

            // Auto-hide success message after 2 seconds (cancel any existing task first)
            successDismissTask?.cancel()
            successDismissTask = Task {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else { return }
                showSuccess = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    ProfileView()
        .environmentObject(StatusViewModel())
}
