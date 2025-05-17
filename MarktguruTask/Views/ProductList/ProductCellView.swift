import SwiftUI

/// Displays a single product cell with title, price, and favorite button.
struct ProductCellView: View {
    // MARK: - Properties
    
    let product: Product
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {
            ProductImageView(urlString: product.images.first)
                .accessibilityLabel(Text(AccessibilityStrings.productImageLabel(for: product.title)))

            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(product.formattedPrice)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            favoriteView
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityStrings.cellIdentifier(for: product.id))
    }

    private var favoriteView: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                onFavoriteToggle()
            }
        }) {
            Image(systemName: Strings.favoriteImageName(isFavorite: isFavorite))
                .foregroundColor(isFavorite ? .red : .gray)
                .imageScale(.large)
        }
        .accessibilityIdentifier(AccessibilityStrings.favoriteButton)
        .accessibilityLabel(Text(AccessibilityStrings.favoriteLabel(isFavorite: isFavorite)))
        .accessibilityHint(Text(AccessibilityStrings.favoriteHint(for: product.title)))
        .buttonStyle(PlainButtonStyle())
    }
}

private extension ProductCellView {
    enum Strings {
        static func favoriteImageName(isFavorite: Bool) -> String {
            isFavorite ? "heart.fill" : "heart"
        }
    }
    enum AccessibilityStrings {
        static func productImageLabel(for title: String) -> String {
            "Product image for \(title)"
        }
        static let favoriteButton = "favoriteButton"
        static func favoriteLabel(isFavorite: Bool) -> String {
            isFavorite ? "Unmark as favorite" : "Mark as favorite"
        }
        static func favoriteHint(for title: String) -> String {
            "Toggles favorite status for \(title)"
        }
        static func cellIdentifier(for id: Int) -> String {
            "productCell_\(id)"
        }
    }
}

#if DEBUG
struct ProductCellView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCellView(
            product: Product(
                id: 1,
                title: "Sample Product",
                price: 49.99,
                description: "A cool product.",
                images: ["https://placehold.co/200x200"]
            ),
            isFavorite: true,
            onFavoriteToggle: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
