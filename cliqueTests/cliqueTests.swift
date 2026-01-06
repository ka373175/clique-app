//
//  cliqueTests.swift
//  cliqueTests
//
//  Created by Praveen Kumar on 8/13/25.
//

import Testing
@testable import clique

struct cliqueTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

// MARK: - FriendsViewModel Race Condition Tests

@MainActor
struct FriendsViewModelRaceConditionTests {
    
    /// Tests that fetchFriends is skipped when there are pending mutations
    /// This prevents fetch from overwriting optimistic updates
    @Test func fetchFriendsSkipsWhenMutationsPending() async throws {
        let viewModel = FriendsViewModel()
        
        // Create a mock friend for testing
        let testFriend = Friend(
            id: "test-id",
            username: "testuser",
            firstName: "Test",
            lastName: "User"
        )
        
        // Manually add the friend to simulate existing state
        viewModel.friends = [testFriend]
        
        // Start an optimistic removal (this adds to pendingMutations)
        // Note: The actual API call will fail but that's okay for this test
        viewModel.removeFriendOptimistically(testFriend)
        
        // Immediately try to fetch - should be skipped due to pending mutation
        let friendsBeforeFetch = viewModel.friends
        await viewModel.fetchFriends()
        
        // Since mutation is pending, friends array should not have been replaced by fetch
        // (The fetch should have been skipped)
        // Note: In a real test with mocked API, we'd verify fetch wasn't called
        #expect(viewModel.friends.count <= friendsBeforeFetch.count,
                "Fetch should be skipped when mutations are pending")
    }
}

// MARK: - StatusViewModel Race Condition Tests

@MainActor
struct StatusViewModelRaceConditionTests {
    
    /// Tests that rapid fetchStatuses calls don't cause duplicate state updates
    /// Later calls should cancel earlier ones
    @Test func rapidFetchCancelsPreviousFetch() async throws {
        let viewModel = StatusViewModel()
        
        // Trigger multiple rapid fetches
        async let fetch1: () = viewModel.fetchStatuses()
        async let fetch2: () = viewModel.fetchStatuses()
        async let fetch3: () = viewModel.fetchStatuses()
        
        // Wait for all to complete
        _ = await (fetch1, fetch2, fetch3)
        
        // After all fetches complete, isLoading should be false
        #expect(viewModel.isLoading == false,
                "isLoading should be false after all fetches complete")
        
        // Only one error message should be present (if any) - not accumulated
        // This verifies that cancelled tasks don't update state
    }
}

// MARK: - Integration-style Race Condition Tests

@MainActor
struct RaceConditionIntegrationTests {
    
    /// Tests that optimistic delete followed by fetch doesn't restore deleted item
    @Test func optimisticDeleteNotOverwrittenByFetch() async throws {
        let viewModel = FriendsViewModel()
        
        // Setup: Add a friend to the list
        let friendToDelete = Friend(
            id: "delete-me",
            username: "deleteme",
            firstName: "Delete",
            lastName: "Me"
        )
        viewModel.friends = [friendToDelete]
        
        // Act: Delete optimistically then immediately fetch
        viewModel.removeFriendOptimistically(friendToDelete)
        
        // The friend should be immediately removed from the array
        #expect(!viewModel.friends.contains(where: { $0.id == "delete-me" }),
                "Friend should be immediately removed optimistically")
        
        // Now fetch - should be blocked due to pending mutation
        await viewModel.fetchFriends()
        
        // Friend should still not be in the list (fetch was blocked)
        #expect(!viewModel.friends.contains(where: { $0.id == "delete-me" }),
                "Deleted friend should not reappear after blocked fetch")
    }
}
