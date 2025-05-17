import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let images: [String]
}

extension Product {
    var formattedPrice: String {
        "$\(String(format: "%.2f", price))"
    }
}
