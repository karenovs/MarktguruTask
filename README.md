# MarktguruTask

A SwiftUI product browser app, built as a technical assignment.

---

## Architectural Decisions

- **MVVM (Model-View-ViewModel) pattern** was used for clear separation of concerns, scalable code, and testability.
- **Type-safe navigation** is implemented using a custom `NavigationRouter` enum with SwiftUI’s `NavigationStack`.
- **Favorites state** is managed with a dedicated `FavoritesStore` (using `Set<Int>` for efficiency), decoupled from the view models and persisted with `UserDefaults` via a protocol abstraction.
- **Image loading and caching** uses [SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI) for efficient async handling and error fallback.
- **Reusable and modular UI components**: The project splits main UI into small, testable views like `ProductCellView`, `ProductImageView`, and custom modifiers such as `onFirstAppear`.
- **Accessibility** is considered for product images and favorite buttons.
- **Dark mode toggle** is persisted and updates the whole app instantly.

---

## Assumptions or Limitations

- **Persistence** uses `UserDefaults` for both favorites and settings, which is appropriate for this scope; for production, CoreData or another robust solution could be used.
- The API is assumed to always return products in the expected format. Minimal defensive checks are included.
- **Networking** has basic error handling but no advanced retry/cancellation for simplicity.
- Product images that fail to load (invalid, SVG, unreachable URLs, etc.) show a default placeholder.
- **No authentication/user accounts** are present—favorites are per-device.
- App does not support iPad split-view (could be easily extended).
- **AI tools** (ChatGPT) were used for architectural brainstorming, code review, and documentation improvement (see below).

---

## Time Spent

- **Total:** Approximately 14 hours  
    - Initial architecture, setup, networking: 2 hours
    - UI implementation: 4 hours
    - State management, favorites, persistence: 3 hours
    - Testing, code review, documentation, polish: 5 hours

---

## Usage of AI

- **OpenAI’s ChatGPT** was used to:
    - Discuss optimal architecture and SwiftUI patterns
    - Get code review and suggestions for modularity, accessibility, and state management
    - Polish code comments and sectioning (e.g., `// MARK:`), and write this README

**All logic and implementation were written and understood by me.  
AI was used strictly as a productivity and review tool, not as a replacement for software development.**

---

## Notes on Modern Swift Testing and Concurrency

This project uses Apple’s modern [Swift Testing framework](https://developer.apple.com/documentation/swift-testing/) and is fully compatible with Swift’s structured concurrency and actor isolation model.

### Why are some initializers in tests called with `await`, even if not marked as `async`?

- In modern Swift, if an initializer is marked with `@MainActor` (such as `@MainActor init(...)`), Swift treats it as potentially “suspendable,” because actor isolation may require scheduling work on the main actor.
- In the new Swift Testing framework (and sometimes in XCTest), constructing any `@MainActor` object in a test requires `await`, even if the initializer is not explicitly `async`.
- This helps ensure your tests are concurrency-safe and actor-isolated, and prepares your code for future Swift concurrency updates.

**Example:**
```swift
let vm = await ProductListViewModel(productService: mockService)
```

---

## How to Run

1. Clone the repository
2. Open `MarktguruTask.xcodeproj` in Xcode 15+
3. Run on a simulator or device with iOS 16+

---

**Thank you for reviewing this assignment!**  
Please feel free to reach out with any questions about architectural decisions or further improvements.
