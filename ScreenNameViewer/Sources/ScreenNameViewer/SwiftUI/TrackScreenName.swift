import SwiftUI

public extension View {

    /// Track the current navigation route for the overlay using your
    /// `NavigationStack(path:)` array. The last element of the path is
    /// rendered as the current route name. Apply once to the
    /// `NavigationStack` (or any ancestor that has access to the path); do
    /// not attach to individual destination views.
    ///
    /// In RELEASE builds this modifier is a no-op.
    func trackScreenName<H: Hashable>(path: [H]) -> some View {
        let name = path.last.map { String(describing: $0) }
        return modifier(_TrackScreenNameModifier(routeName: name))
    }

    /// Track an explicit route name for the overlay. Pass `nil` to clear.
    /// In RELEASE builds this modifier is a no-op.
    func trackScreenName(_ routeName: String?) -> some View {
        modifier(_TrackScreenNameModifier(routeName: routeName))
    }
}

private struct _TrackScreenNameModifier: ViewModifier {

    let routeName: String?

    func body(content: Content) -> some View {
        #if DEBUG
        content
            .onAppear { Tracker.shared.updateRoute(routeName) }
            .onChange(of: routeName) { _, newValue in
                Tracker.shared.updateRoute(newValue)
            }
            .onDisappear { Tracker.shared.updateRoute(nil) }
        #else
        content
        #endif
    }
}
