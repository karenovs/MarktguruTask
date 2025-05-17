import Foundation

class MockPersistenceManager: PersistenceManagerProtocol {
    var favoriteIDs: Set<Int> = []
    var darkMode: Bool = false

    func getFavoriteProductIDs() -> [Int] { Array(favoriteIDs) }
    func saveFavoriteProductIDs(_ ids: [Int]) { favoriteIDs = Set(ids) }
    func isFavorite(productID: Int) -> Bool { favoriteIDs.contains(productID) }
    func toggleFavorite(productID: Int) {
        if !favoriteIDs.insert(productID).inserted { favoriteIDs.remove(productID) }
    }

    func isDarkModeEnabled() -> Bool { darkMode }
    func setDarkMode(enabled: Bool) { darkMode = enabled }
}
