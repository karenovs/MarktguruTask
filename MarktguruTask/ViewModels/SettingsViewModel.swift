import Foundation

/// ViewModel for the settings screen, managing dark mode state and persistence.
@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isDarkModeEnabled: Bool = false

    // MARK: - Private Properties

    private let persistenceManager: PersistenceManagerProtocol

    // MARK: - Init

    init(persistenceManager: PersistenceManagerProtocol) {
        self.persistenceManager = persistenceManager
        loadSettings()
    }

    // MARK: - Load Settings

    private func loadSettings() {
        isDarkModeEnabled = persistenceManager.isDarkModeEnabled()
    }

    // MARK: - Dark Mode
    
    func toggleDarkMode(isOn: Bool) {
        isDarkModeEnabled = isOn
        persistenceManager.setDarkMode(enabled: isOn)
    }
}
