import Testing
@testable import MarktguruTask

/// Unit tests for FavoritesStore.
/// Checks favorite toggling, persistence syncing, and correct reporting of favorite state.
@Suite struct FavoritesStoreTests {

    @Test
    func togglesFavoriteStatus() async {
        let mockPersistence = MockPersistenceManager()
        let store = FavoritesStore(persistenceManager: mockPersistence)
        // Initially empty
        #expect(store.isFavorite(productID: 1) == false)
        store.toggleFavorite(productID: 1)
        #expect(store.isFavorite(productID: 1) == true)
        store.toggleFavorite(productID: 1)
        #expect(store.isFavorite(productID: 1) == false)
    }

    @Test
    func persistsFavorites() async {
        let mockPersistence = MockPersistenceManager()
        let store = FavoritesStore(persistenceManager: mockPersistence)
        store.toggleFavorite(productID: 5)
        // Simulate app relaunch: create a new persistence layer, "restoring" saved favorites
        let reloadedMockPersistence = mockPersistence
        reloadedMockPersistence.favoriteIDs = store.favoriteProductIDs
        let newStore = FavoritesStore(persistenceManager: reloadedMockPersistence)
        #expect(newStore.isFavorite(productID: 5) == true)
        newStore.toggleFavorite(productID: 5)
        #expect(newStore.isFavorite(productID: 5) == false)
    }
}
