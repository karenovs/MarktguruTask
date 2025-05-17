import SwiftUI

/// Shows details of a product with image, description, and favorite toggle.
struct ProductDetailView: View {
    // MARK: - Properties

    let product: Product
    @EnvironmentObject var favoritesStore: FavoritesStore

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ProductImageView(
                    urlString: product.images.first,
                    width: UIScreen.main.bounds.width - 32,
                    height: 250,
                    cornerRadius: 8
                )
                .accessibilityLabel(Text(AccessibilityStrings.productImageLabel(for: product.title)))

                HStack {
                    Text(product.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .accessibilityIdentifier(AccessibilityStrings.titleLabel)

                    Spacer()

                    favoriteView
                }

                Text(product.formattedPrice)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(product.description)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding()
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var favoriteView: some View {
        let isFavorite = favoritesStore.isFavorite(productID: product.id)

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                favoritesStore.toggleFavorite(productID: product.id)
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

private extension ProductDetailView {
    enum Strings {
        static func favoriteImageName(isFavorite: Bool) -> String {
            isFavorite ? "heart.fill" : "heart"
        }
    }
    enum AccessibilityStrings {
        static func productImageLabel(for title: String) -> String {
            "Product image for \(title)"
        }
        static let titleLabel = "productTitleLabel"
        static let favoriteButton = "favoriteButton"
        static func favoriteLabel(isFavorite: Bool) -> String {
            isFavorite ? "Unmark as favorite" : "Mark as favorite"
        }
        static func favoriteHint(for title: String) -> String {
            "Toggles favorite status for \(title)"
        }
    }
}

#if DEBUG
struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(
            product: Product(
                id: 1,
                title: "Sample Product",
                price: 49.99,
                description: "A very nice product you might love.",
                images: ["https://placehold.co/400x300"]
            )
        )
        .environmentObject(FavoritesStore(persistenceManager: MockPersistenceManager()))
    }
}
#endif
