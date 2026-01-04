//
//  SetStatusView.swift
//  clique
//
//  Created by Praveen Kumar on 9/15/25.
//

import SwiftUI

struct SetStatusView: View {
    @EnvironmentObject var viewModel: StatusViewModel
    @State private var statusEmoji: String = ""
    @State private var statusText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccess: Bool = false
    @State private var hasPrefilled: Bool = false
    @FocusState private var isTextEditorFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Emoji Input
                VStack(spacing: 8) {
                    EmojiTextField(text: $statusEmoji, placeholder: "+")
                        .frame(width: 100, height: 100)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                    
                    Text("Tap to add emoji")
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
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(statusText.isEmpty ? Color.gray : Color.black)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                }
                .disabled(statusText.isEmpty || isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .contentShape(Capsule())
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isTextEditorFocused = false
            }
            .navigationTitle("Set Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isTextEditorFocused {
                        Button("Done") {
                            isTextEditorFocused = false
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: errorMessage)
            .animation(.easeInOut(duration: 0.2), value: showSuccess)
            .animation(.easeInOut(duration: 0.2), value: isTextEditorFocused)
            .onAppear {
                prefillCurrentStatus()
            }
        }
    }
    
    private func prefillCurrentStatus() {
        // Only prefill once to avoid overwriting user input
        guard !hasPrefilled else { return }
        hasPrefilled = true
        
        if let currentStatus = viewModel.currentUserStatus {
            statusEmoji = currentStatus.statusEmoji ?? ""
            statusText = currentStatus.statusText
        }
    }

    
    private func updateStatus() async {
        isLoading = true
        errorMessage = nil
        showSuccess = false
        
        do {
            try await APIClient.shared.updateStatus(
                emoji: statusEmoji,
                text: statusText
            )
            showSuccess = true
            
            // Auto-hide success message after 2 seconds
            Task {
                try? await Task.sleep(for: .seconds(2))
                showSuccess = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    SetStatusView()
        .environmentObject(StatusViewModel())
}

