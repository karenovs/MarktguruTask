import SwiftUI

/// Enum-based navigation router for type-safe SwiftUI NavigationStack destinations.
/// Extend with more cases as the app grows.
enum NavigationRouter: Hashable {
    case productDetail(product: Product)

    // MARK: - ViewBuilder

    /// Returns the destination view for a navigation route.
    @ViewBuilder
    func destinationView() -> some View {
        switch self {
        case .productDetail(let product):
            ProductDetailView(product: product)
        }
    }
}
