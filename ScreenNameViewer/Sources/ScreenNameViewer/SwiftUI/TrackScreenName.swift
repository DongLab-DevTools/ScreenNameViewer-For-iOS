import SwiftUI

public extension View {

    /// Track the current navigation route for the overlay using your
    /// `NavigationStack(path:)` array. The last element of the path is
    /// rendered as the current route name.
    ///
    /// In RELEASE builds this modifier is a no-op.
    func trackScreenName<H: Hashable>(path: [H]) -> some View {
        let name = path.last.map { String(describing: $0) }
        return modifier(_TrackScreenNameModifier(routeName: name))
    }

    /// Track an explicit route name for the overlay. Pass `nil` to clear.
    /// Stack-friendly: nesting another `.trackScreenName(...)` (for example on
    /// a `.sheet` or a `TabView` child) overrides this one while it is on
    /// screen, then the previous value is restored automatically.
    ///
    /// In RELEASE builds this modifier is a no-op.
    func trackScreenName(_ routeName: String?) -> some View {
        modifier(_TrackScreenNameModifier(routeName: routeName))
    }
}

private struct _TrackScreenNameModifier: ViewModifier {

    let routeName: String?

    // A stable identifier for this modifier instance. The Tracker keeps an
    // ordered set of (id, name) pairs; on appear the modifier registers,
    // on change it updates its entry, on disappear it removes it. This makes
    // sheet dismissals and tab swaps resolve to the entry that's still on
    // screen instead of being clobbered by a stray "set to nil" call.
    @State private var id = UUID()

    func body(content: Content) -> some View {
        #if DEBUG
        content
            .onAppear { Tracker.shared.setRoute(id: id, name: routeName) }
            .onChange(of: routeName) { _, new in
                Tracker.shared.setRoute(id: id, name: new)
            }
            .onDisappear { Tracker.shared.removeRoute(id: id) }
        #else
        content
        #endif
    }
}
