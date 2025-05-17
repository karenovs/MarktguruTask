import Foundation

/// Protocol defining a generic API client for making requests.
protocol APIClientProtocol {
    /// Performs an async request for a given endpoint and decodes the response.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

/// Concrete implementation of APIClientProtocol using URLSession.
struct APIClient: APIClientProtocol {
    /// Performs the network request and decodes the data to the specified type.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // Execute the network call using the URLRequest from the endpoint
        let (data, response) = try await URLSession.shared.data(for: endpoint.urlRequest)
        // Ensure the response status code is in the 2xx range
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        // Attempt to decode the returned data
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

/// Describes the API endpoint, including path and query parameters.
struct APIEndpoint {
    let path: String               // The endpoint path, e.g. "/products"
    let queryItems: [URLQueryItem] // Query parameters for the request

    /// Builds a URLRequest using the scheme, host, and path.
    var urlRequest: URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.escuelajs.co"
        components.path = "/api/v1" + path
        components.queryItems = queryItems
        // Force-unwrap is safe if the path is constructed properly, otherwise fatalError can be used
        let url = components.url
        return URLRequest(url: url!)
    }
}

// MARK: - API Error Types

extension APIClient {
    /// Defines possible errors returned by the APIClient.
    enum APIError: Error {
        case invalidResponse       // Non-2xx status code
        case decodingError(Error)  // Decoding JSON failed
        case invalidURL            // Malformed URL
    }
}
