import SwiftUI

struct MainTabView: View {
    // MARK: - Properties

    // I created ProductListViewModel as a @StateObject in MainTabView so that the product list state
    // (loaded products, pagination, etc.) persists when switching between tabs or navigating back
    // from product details. This avoids unnecessary reloads, ensures smoother user experience,
    // and allows for state sharing between ProductListView and other views if needed.
    @StateObject private var productListViewModel: ProductListViewModel
    let settingsViewModel: SettingsViewModel
    let productService: ProductServiceProtocol

    // MARK: - Init

    init(settingsViewModel: SettingsViewModel, productService: ProductServiceProtocol) {
        self.settingsViewModel = settingsViewModel
        self.productService = productService
        _productListViewModel = StateObject(wrappedValue: ProductListViewModel(productService: productService))
    }

    // MARK: - Body

    var body: some View {
        TabView {
            ProductListView(viewModel: productListViewModel)
                .tabItem { Label(Strings.productsTab, systemImage: Strings.productsIcon) }

            SettingsView(viewModel: settingsViewModel)
                .tabItem { Label(Strings.settingsTab, systemImage: Strings.settingsIcon) }
        }
    }
}

private extension MainTabView {
    enum Strings {
        static let productsTab = "Products"
        static let settingsTab = "Settings"
        static let productsIcon = "list.bullet"
        static let settingsIcon = "gearshape"
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide mocks for dependencies
        let mockPersistence = MockPersistenceManager()
        let mockSettingsVM = SettingsViewModel(persistenceManager: mockPersistence)
        let mockProductService = MockProductService()

        MainTabView(
            settingsViewModel: mockSettingsVM,
            productService: mockProductService
        )
        .environmentObject(FavoritesStore(persistenceManager: mockPersistence))
    }
}
#endif
