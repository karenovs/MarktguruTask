import Testing
@testable import MarktguruTask

/// Unit tests for ProductListViewModel.
/// Covers loading, pagination, and error state.
@Suite struct ProductListViewModelTests {

    @Test
    func loadsProductsFromMockService() async {
        let mockService = MockProductService()
        mockService.products = [
            Product(id: 1, title: "Product 1", price: 10, description: "Desc", images: [])
        ]
        let vm = await ProductListViewModel(productService: mockService)

        await vm.loadProducts()
        await #expect(vm.products.count == 1)
        await #expect(vm.products.first?.title == "Product 1")
        await #expect(vm.isLoading == false)
        await #expect(vm.errorMessage == nil)
    }

    @Test
    func handlesPagination() async {
        let mockService = MockProductService()
        mockService.products = (1...25).map { i in
            Product(id: i, title: "Product \(i)", price: Double(i), description: "", images: [])
        }
        let vm = await ProductListViewModel(productService: mockService)

        await vm.loadProducts()
        await #expect(vm.products.count == 10)

        // Trigger pagination with the correct threshold item
        let thresholdIndex1 = await vm.products.index(vm.products.endIndex, offsetBy: -3)
        await vm.loadMoreProductsIfNeeded(currentItem: vm.products[thresholdIndex1])
        await #expect(vm.products.count == 20)

        // Trigger second pagination with new threshold
        let thresholdIndex2 = await vm.products.index(vm.products.endIndex, offsetBy: -3)
        await vm.loadMoreProductsIfNeeded(currentItem: vm.products[thresholdIndex2])
        await #expect(vm.products.count == 25)
    }

    @Test
    func handlesEmptyState() async {
        let mockService = MockProductService()
        let vm = await ProductListViewModel(productService: mockService)

        await vm.loadProducts()
        await #expect(vm.products.isEmpty)
        await #expect(vm.isLoading == false)
        await #expect(vm.errorMessage == nil)
    }

    @Test
    func handlesErrorState() async {
        let mockService = MockProductService()
        enum DummyError: Error { case test }
        mockService.error = DummyError.test
        let vm = await ProductListViewModel(productService: mockService)

        await vm.loadProducts()
        await #expect(vm.products.isEmpty)
        await #expect(vm.errorMessage == "Failed to load products.")
        await #expect(vm.isLoading == false)
    }
}
