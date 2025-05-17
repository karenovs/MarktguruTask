import SwiftUI
import SDWebImageSwiftUI

/// A reusable image view that loads images from a URL with async loading, failure handling, and placeholder support.
///
/// - Displays a placeholder system image if the image fails to load or the URL is nil/empty.
/// - Uses SDWebImageSwiftUI for efficient image caching and async loading.
/// - Shows a progress view while loading.
struct ProductImageView: View {
    // MARK: - Properties

    let urlString: String?
    var width: CGFloat = 80
    var height: CGFloat = 80
    var cornerRadius: CGFloat = 8

    // MARK: - State

    @State private var loadFailed = false

    // Static cache of failed URLs (lives for the session)
    private static var failedURLs = Set<String>()

    var isObviouslyInvalidImage: Bool {
        urlString?.isEmpty ?? true
    }

    var isKnownFailed: Bool {
        guard let urlString else { return false }
        return ProductImageView.failedURLs.contains(urlString)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            if loadFailed || isObviouslyInvalidImage || isKnownFailed {
                // Placeholder when image fails or no URL provided
                placeholderImageView
            } else {
                imageView
            }
        }
        .frame(width: width, height: height)
        .cornerRadius(cornerRadius)
    }

    private var imageView: some View {
        // Async image loading with progress indicator and failure handling
        WebImage(url: URL(string: urlString ?? "")) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
                .frame(width: width, height: height)
        }
        .onFailure { _ in
            if let urlString = urlString {
                ProductImageView.failedURLs.insert(urlString)
            }
            DispatchQueue.main.async {
                loadFailed = true
            }
        }
        .indicator(.activity)
        .transition(.fade)
        .scaledToFill()
        .frame(width: width, height: height)
        .clipped()
        .cornerRadius(cornerRadius)
        .background(Color.gray.opacity(0.1))
    }

    private var placeholderImageView: some View {
        ZStack {
            Color.gray.opacity(0.1)
            Image(systemName: Strings.placeholderSystemImage)
                .resizable()
                .scaledToFit()
                .frame(width: width / 2, height: height / 2)
                .foregroundColor(.gray.opacity(0.7))
                .accessibilityLabel(Strings.placeholderAccessibilityLabel)
        }
    }
}

private extension ProductImageView {
    enum Strings {
        static let placeholderSystemImage = "photo"
        static let placeholderAccessibilityLabel = "Placeholder image"
    }
}

#if DEBUG
struct ProductImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProductImageView(urlString: "https://placehold.co/200x200")
            ProductImageView(urlString: nil)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
