import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(offset: Int, limit: Int) async throws -> [Product]
}
