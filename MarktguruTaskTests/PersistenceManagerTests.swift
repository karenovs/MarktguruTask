import Testing
import Foundation
@testable import MarktguruTask

/// Unit tests for PersistenceManager.
/// Ensures correct saving and loading of favorites and dark mode state using UserDefaults or a custom suite.
@Suite struct PersistenceManagerTests {

    @Test
    func savesAndLoadsFavoriteProductIDs() async {
        let suiteName = "PersistenceManagerTests-\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        let persistence = PersistenceManager(userDefaults: userDefaults)

        // Should start empty
        #expect(persistence.getFavoriteProductIDs().isEmpty)

        // Save and retrieve
        persistence.saveFavoriteProductIDs([1, 2, 3])
        #expect(persistence.getFavoriteProductIDs() == [1, 2, 3])

        // Overwrite and retrieve
        persistence.saveFavoriteProductIDs([5])
        #expect(persistence.getFavoriteProductIDs() == [5])

        // Cleanup
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    @Test
    func savesAndLoadsDarkMode() async {
        let suiteName = "PersistenceManagerTests-\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        let persistence = PersistenceManager(userDefaults: userDefaults)

        // Default should be false
        #expect(!persistence.isDarkModeEnabled())

        // Set to true and check
        persistence.setDarkMode(enabled: true)
        #expect(persistence.isDarkModeEnabled())

        // Set back to false
        persistence.setDarkMode(enabled: false)
        #expect(!persistence.isDarkModeEnabled())

        // Cleanup
        userDefaults.removePersistentDomain(forName: suiteName)
    }
}
