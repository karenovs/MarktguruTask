import Foundation

protocol PersistenceManagerProtocol {
    // Favorites
    func getFavoriteProductIDs() -> [Int]
    func saveFavoriteProductIDs(_ ids: [Int])
    func isFavorite(productID: Int) -> Bool
    func toggleFavorite(productID: Int)

    // Settings
    func isDarkModeEnabled() -> Bool
    func setDarkMode(enabled: Bool)
}
