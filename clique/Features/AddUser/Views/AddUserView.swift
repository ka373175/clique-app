//
//  AddUserView.swift
//  clique
//
//  Created by Praveen Kumar on 9/15/25.
//

import SwiftUI

struct AddUserView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var showingAddSheet = false
    @State private var friendToDelete: Friend?
    @State private var showingDeleteConfirmation = false
    @State private var errorPresented = false
    
    var body: some View {
        NavigationStack {
            friendsListContent
                .navigationTitle("Friends")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        addButton
                    }
                }
                .refreshable {
                    await viewModel.fetchFriends()
                }
                .overlay { overlayContent }
                .task {
                    if viewModel.friends.isEmpty {
                        await viewModel.fetchFriends()
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    AddFriendSheet(viewModel: viewModel)
                }
                .alert("Remove Friend", isPresented: $showingDeleteConfirmation) {
                    deleteAlertButtons
                } message: {
                    deleteAlertMessage
                }
                .onChange(of: viewModel.errorMessage) { _, newValue in
                    if newValue != nil {
                        errorPresented = true
                    }
                }
                .alert("Error", isPresented: $errorPresented) {
                    Button("OK") {
                        viewModel.errorMessage = nil
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
        }
    }
    
    // MARK: - Subviews
    
    private var friendsListContent: some View {
        List {
            ForEach(viewModel.friends) { friend in
                FriendRowView(friend: friend)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            friendToDelete = friend
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
    
    private var addButton: some View {
        Button {
            showingAddSheet = true
        } label: {
            Image(systemName: "plus")
                .fontWeight(.semibold)
        }
        .glassEffect(.regular.interactive())
    }
    
    @ViewBuilder
    private var overlayContent: some View {
        if viewModel.isLoading && viewModel.friends.isEmpty {
            ProgressView("Loading...")
        } else if !viewModel.isLoading && viewModel.friends.isEmpty {
            ContentUnavailableView {
                Label("No Friends Yet", systemImage: "person.2.slash")
            } description: {
                Text("Tap the + button to add your first friend!")
            }
        }
    }
    
    @ViewBuilder
    private var deleteAlertButtons: some View {
        Button("Cancel", role: .cancel) {
            friendToDelete = nil
        }
        Button("Remove", role: .destructive) {
            if let friend = friendToDelete {
                Task {
                    _ = await viewModel.removeFriend(friend)
                    friendToDelete = nil
                }
            }
        }
    }
    
    @ViewBuilder
    private var deleteAlertMessage: some View {
        if let friend = friendToDelete {
            Text("Are you sure you want to remove \(friend.fullName) from your friends?")
        }
    }
}

// MARK: - Friend Row View

private struct FriendRowView: View {
    let friend: Friend
    
    var body: some View {
        HStack(spacing: 12) {
            initialsCircle
            nameStack
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var initialsCircle: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
            
            Text(friend.initials)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
    
    private var nameStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(friend.fullName)
                .font(.body)
                .fontWeight(.medium)
            
            Text("@\(friend.username)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Add Friend Sheet

private struct AddFriendSheet: View {
    @ObservedObject var viewModel: FriendsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var isAdding = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                usernameSection
                errorSection
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    confirmButton
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var usernameSection: some View {
        Section {
            TextField("Username", text: $username)
                .textContentType(.username)
                .autocapitalization(.none)
                .autocorrectionDisabled()
        } header: {
            Text("Friend's Username")
        } footer: {
            Text("Enter the exact username of the person you want to add.")
        }
    }
    
    @ViewBuilder
    private var errorSection: some View {
        if let error = errorMessage {
            Section {
                Text(error)
                    .foregroundStyle(.red)
            }
        }
    }
    
    @ViewBuilder
    private var confirmButton: some View {
        if isAdding {
            ProgressView()
        } else {
            Button("Add") {
                Task {
                    await addFriend()
                }
            }
            .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
    
    private func addFriend() async {
        isAdding = true
        errorMessage = nil
        
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        let success = await viewModel.addFriend(username: trimmedUsername)
        
        if success {
            dismiss()
        } else {
            errorMessage = viewModel.errorMessage
        }
        
        isAdding = false
    }
}

#Preview {
    AddUserView()
}
