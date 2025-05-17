import Foundation

/// Handles API calls to fetch product data from the remote server.
/// Implements ProductServiceProtocol for testability.
struct ProductService {
    // MARK: - Properties
    
    let apiClient: APIClientProtocol

    // MARK: - Init

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
}

// MARK: - ProductServiceProtocol

extension ProductService: ProductServiceProtocol {
    /// Fetches products from the API with given offset and limit.
    /// Throws error if URL is invalid, network fails, or decoding fails.
    func fetchProducts(offset: Int, limit: Int) async throws -> [Product] {
        // Inject failure for UI testing
        if ProcessInfo.processInfo.arguments.contains("-UITestNetworkFailure") {
            throw APIClient.APIError.invalidResponse
        }

        let endpoint = APIEndpoint(
            path: "/products",
            queryItems: [
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        )
        return try await apiClient.request(endpoint)
    }
}

extension ProductService {
    enum Error: Swift.Error {
        case invalidURL
        case invalidResponse
        case decodingError(Swift.Error)
    }
}
