import Foundation
import Combine

/// Observable store for favorite product IDs. Uses persistence for saving and loading favorites.
class FavoritesStore: ObservableObject {
    // MARK: - Published Properties

    @Published var favoriteProductIDs: Set<Int> = []

    // MARK: - Private Properties

    private let persistenceManager: PersistenceManagerProtocol

    // MARK: - Init

    init(persistenceManager: PersistenceManagerProtocol) {
        self.persistenceManager = persistenceManager
        self.favoriteProductIDs = Set(persistenceManager.getFavoriteProductIDs())
    }

    // MARK: - Favorites

    /// Checks if a product is marked as favorite.
    func isFavorite(productID: Int) -> Bool {
        favoriteProductIDs.contains(productID)
    }

    /// Toggles the favorite status for a given product ID.
    func toggleFavorite(productID: Int) {
        if !favoriteProductIDs.insert(productID).inserted {
            favoriteProductIDs.remove(productID)
        }

        // Save to persistent storage (as an array, since UserDefaults doesn't support Set directly)
        persistenceManager.saveFavoriteProductIDs(Array(favoriteProductIDs))
    }

    func reloadFavorites() {
        self.favoriteProductIDs = Set(persistenceManager.getFavoriteProductIDs())
    }
}
