import Foundation

class MockProductService: ProductServiceProtocol {
    var products: [Product] = []
    var error: Error?

    func fetchProducts(offset: Int, limit: Int) async throws -> [Product] {
        if let error { throw error }
        return Array(products.dropFirst(offset).prefix(limit))
    }
}
