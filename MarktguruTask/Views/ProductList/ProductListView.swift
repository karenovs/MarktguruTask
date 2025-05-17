import SwiftUI

/// Displays the list of products with infinite scrolling and pagination.
struct ProductListView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: ProductListViewModel
    @State private var navigationPath: [NavigationRouter] = []
    @EnvironmentObject var favoritesStore: FavoritesStore

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.isLoading {
                    // Loading State
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    // Error State
                    errorView(error: error)
                } else if viewModel.products.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    // Empty State
                    emptyView
                } else {
                    // Loaded State
                    productList
                }
            }
            .navigationTitle(Strings.productsTitle)
            .onFirstAppear {
                await viewModel.loadProducts()
            }
            .navigationDestination(for: NavigationRouter.self) { route in
                route.destinationView()
            }
        }
    }

    // MARK: - Components

    /// The product list with pagination
    private var productList: some View {
        List(viewModel.products) { product in
            ForEach(viewModel.products) { product in
                ProductCellView(
                    product: product,
                    isFavorite: favoritesStore.isFavorite(productID: product.id),
                    onFavoriteToggle: {
                        favoritesStore.toggleFavorite(productID: product.id)
                    }
                )
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    0
                }
                .onTapGesture {
                    navigationPath.append(.productDetail(product: product))
                }
                .onAppear {
                    Task {
                        await viewModel.loadMoreProductsIfNeeded(currentItem: product)
                    }
                }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .accessibilityIdentifier(Strings.productList)
        .listStyle(.plain)
    }

    /// Error view with retry button
    private func errorView(error: String) -> some View {
        VStack {
            Text(error)
                .foregroundColor(.red)
                .padding()
                .accessibilityIdentifier(Strings.errorLabel)

            Button(Strings.retryTitle) {
                Task { await viewModel.loadProducts() }
            }
            .padding()
            .accessibilityIdentifier(Strings.retryButton)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Empty products view
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: Strings.emptyImage)
                .font(.system(size: 44))
                .foregroundColor(.gray.opacity(0.4))
            Text(Strings.noProducts)
                .foregroundColor(.secondary)
                .font(.title3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension ProductListView {
    enum Strings {
        static let errorLabel = "errorMessageLabel"
        static let retryButton = "retryButton"
        static let retryTitle = "Retry"
        static let emptyImage = "tray"
        static let noProducts = "No products found"
        static let productsTitle = "Products"
        static let productList = "productList"
    }
}

#if DEBUG
// MARK: - ProductListView Previews

/// A simple mock service for SwiftUI Previews
struct PreviewProductService: ProductServiceProtocol {
    func fetchProducts(offset: Int, limit: Int) async throws -> [Product] {
        [
            Product(id: 1, title: "Shirt", price: 29.99, description: "A nice shirt.", images: ["https://placehold.co/100x100"]),
            Product(id: 2, title: "Hat", price: 9.99, description: "A stylish hat.", images: ["https://placehold.co/100x100"])
        ]
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ProductListViewModel(productService: PreviewProductService())
        // Manually set products synchronously for preview purposes
        // (Or if using async, you can run an async task in init)
        Task { await viewModel.loadProducts() }
        return ProductListView(viewModel: viewModel)
            .environmentObject(FavoritesStore(persistenceManager: MockPersistenceManager()))
    }
}
#endif
