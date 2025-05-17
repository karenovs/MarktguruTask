import SwiftUI

/// Settings screen, currently allows toggling dark mode preference.
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(Strings.appearanceSectionHeader)) {
                    Toggle(isOn: $viewModel.isDarkModeEnabled) {
                        Label(Strings.darkModeLabel, systemImage: Strings.darkModeSystemImage)
                    }
                    .accessibilityIdentifier(AccessibilityStrings.darkModeSwitch)
                    .accessibilityValue(AccessibilityStrings.darkModeValue(for: viewModel.isDarkModeEnabled))
                    .accessibilityLabel(AccessibilityStrings.darkModeToggleLabel)
                    .onChange(of: viewModel.isDarkModeEnabled) {
                        viewModel.toggleDarkMode(isOn: viewModel.isDarkModeEnabled)
                    }
                }
            }
            .navigationTitle(Strings.navigationTitle)
        }
    }
}

private extension SettingsView {
    enum Strings {
        static let appearanceSectionHeader = "Appearance"
        static let darkModeLabel = "Dark Mode"
        static let darkModeSystemImage = "moon.fill"
        static let navigationTitle = "Settings"
    }

    enum AccessibilityStrings {
        static let darkModeSwitch = "darkModeSwitch"
        static let darkModeToggleLabel = "Dark Mode Toggle"
        static func darkModeValue(for enabled: Bool) -> String {
            enabled ? "1" : "0"
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let mock: MockPersistenceManager = {
            let manager = MockPersistenceManager()
            manager.darkMode = true // or false
            return manager
        }()
        let vm = SettingsViewModel(persistenceManager: mock)
        return SettingsView(viewModel: vm)
    }
}
#endif
