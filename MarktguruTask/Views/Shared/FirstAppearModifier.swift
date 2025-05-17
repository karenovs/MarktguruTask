import SwiftUI

/// A view modifier that ensures an async action runs only once on first appearance of a view.
public struct FirstAppearModifier: ViewModifier {
    // MARK: - Properties

    private let action: () async -> Void
    @State private var hasAppeared = false

    // MARK: - Init

    /// Creates a modifier that will call the given async action only once.
    public init(_ action: @escaping () async -> Void) {
        self.action = action
    }

    // MARK: - ViewModifier

    public func body(content: Content) -> some View {
        content
            .task {
                guard !hasAppeared else { return }
                hasAppeared = true
                await action()
            }
    }
}

// MARK: - View Extension

/// Makes the view perform an async action only on its first appearance.
public extension View {
    func onFirstAppear(_ action: @escaping () async -> Void) -> some View {
        modifier(FirstAppearModifier(action))
    }
}
