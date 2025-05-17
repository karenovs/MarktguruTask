import SwiftUI
import SDWebImage

@main
struct MarktguruTaskApp: App {
    @StateObject private var settingsViewModel: SettingsViewModel
    @StateObject private var favoritesStore: FavoritesStore
    private let productService: ProductService

    init() {
        SDWebImageDownloader.shared.config.downloadTimeout = 4

        productService = ProductService()
        var persistenceManager = PersistenceManager()

        /// During UI tests, inject a separate UserDefaults suite to isolate test data and prevent polluting real app data.
        /// If the `-UITest_ResetDefaults` launch argument is present, the suite will be cleaned before launch.
        /// This allows tests to start with a clean slate and ensures favorites, settings, etc. do not leak between test runs.
        if let suiteIndex = ProcessInfo.processInfo.arguments.firstIndex(of: "-UITest_UserDefaultsSuite"),
           suiteIndex + 1 < ProcessInfo.processInfo.arguments.count {
            let suiteName = ProcessInfo.processInfo.arguments[suiteIndex + 1]
            let userDefaults = UserDefaults(suiteName: suiteName)!

            if ProcessInfo.processInfo.arguments.contains("-UITest_ResetDefaults") {
                userDefaults.removePersistentDomain(forName: suiteName)
                userDefaults.synchronize()
            }
            persistenceManager = PersistenceManager(userDefaults: userDefaults)
        }

        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(persistenceManager: persistenceManager))
        _favoritesStore = StateObject(wrappedValue: FavoritesStore(persistenceManager: persistenceManager))
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(settingsViewModel: settingsViewModel, productService: productService)
                .preferredColorScheme(settingsViewModel.isDarkModeEnabled ? .dark : .light)
                .environmentObject(favoritesStore)
        }
    }
}
