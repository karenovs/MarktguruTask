import Foundation

/// Manages persistent storage for favorites and settings using UserDefaults.
/// Supports testability via custom UserDefaults suites.
struct PersistenceManager {
    // MARK: - Properties

    private let defaults: UserDefaults

    // MARK: - Init

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
    }

    private enum Keys {
        static let favoriteProductIDs = "favoriteProductIDs"
        static let darkModeEnabled = "darkModeEnabled"
    }
}

// MARK: - PersistenceManagerProtocol

extension PersistenceManager: PersistenceManagerProtocol {
    // MARK: - Favorites

    func getFavoriteProductIDs() -> [Int] {
        defaults.array(forKey: Keys.favoriteProductIDs) as? [Int] ?? []
    }

    func saveFavoriteProductIDs(_ ids: [Int]) {
        defaults.set(ids, forKey: Keys.favoriteProductIDs)
    }

    func isFavorite(productID: Int) -> Bool {
        getFavoriteProductIDs().contains(productID)
    }

    func toggleFavorite(productID: Int) {
        var ids = getFavoriteProductIDs()
        if ids.contains(productID) {
            ids.removeAll { $0 == productID }
        } else {
            ids.append(productID)
        }
        saveFavoriteProductIDs(ids)
    }

    // MARK: - Dark Mode Setting

    func isDarkModeEnabled() -> Bool {
        defaults.bool(forKey: Keys.darkModeEnabled)
    }

    func setDarkMode(enabled: Bool) {
        defaults.set(enabled, forKey: Keys.darkModeEnabled)
    }
}
