import Foundation

/// View model for managing the product list, loading, pagination, and error handling.
@MainActor
class ProductListViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private var offset = 0
    private let limit = 10
    private var canLoadMore = true
    private let productService: ProductServiceProtocol

    // MARK: - Init

    init(productService: ProductServiceProtocol) {
        self.productService = productService
    }

    // MARK: - Load Products

    /// Loads the first page of products from the API and resets pagination.
    func loadProducts() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        offset = 0 // Reset pagination

        do {
            let newProducts = try await productService.fetchProducts(offset: offset, limit: limit)
            products = newProducts
            canLoadMore = !newProducts.isEmpty
        } catch {
            errorMessage = "Failed to load products."
        }

        isLoading = false
    }

    // MARK: - Load More Products (Pagination)

    /// Loads more products if the user scrolls near the end of the list.
    func loadMoreProductsIfNeeded(currentItem: Product?) async {
        guard let currentItem = currentItem else {
            return
        }

        let thresholdIndex = products.index(products.endIndex, offsetBy: -3)
        if products.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            await loadMoreProducts()
        }
    }

    private func loadMoreProducts() async {
        guard !isLoadingMore, canLoadMore else { return }

        isLoadingMore = true
        errorMessage = nil
        offset += limit

        do {
            let newProducts = try await productService.fetchProducts(offset: offset, limit: limit)
            products.append(contentsOf: newProducts)
            canLoadMore = !newProducts.isEmpty
        } catch {
            errorMessage = "Failed to load more products."
        }

        isLoadingMore = false
    }
}
