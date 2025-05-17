import Testing
@testable import MarktguruTask

/// Unit tests for SettingsViewModel.
/// Verifies dark mode state loads from storage, persists on toggle, and syncs correctly with UserDefaults.
@Suite struct SettingsViewModelTests {

    @Test
    func savesAndLoadsDarkModeState() async {
        let mockPersistence = MockPersistenceManager()
        let vm = await SettingsViewModel(persistenceManager: mockPersistence)

        // Should load initial state (false)
        await #expect(vm.isDarkModeEnabled == false)

        // Enable dark mode and persist
        await vm.toggleDarkMode(isOn: true)
        await #expect(vm.isDarkModeEnabled == true)
        #expect(mockPersistence.darkMode == true)

        // Simulate app relaunch: create a new ViewModel with the same persisted value
        let reloadedPersistence = MockPersistenceManager()
        reloadedPersistence.darkMode = mockPersistence.darkMode
        let newVM = await SettingsViewModel(persistenceManager: reloadedPersistence)

        await #expect(newVM.isDarkModeEnabled == true)

        // Disable dark mode and check again
        await newVM.toggleDarkMode(isOn: false)
        await #expect(newVM.isDarkModeEnabled == false)
        #expect(reloadedPersistence.darkMode == false)
    }
}
