import Foundation

/// Public entry point for the screen-name overlay.
///
/// Calling `ScreenNameViewer.start()` once at app launch is enough — every
/// `UIViewController` that becomes visible is then displayed in a passthrough
/// overlay window. In RELEASE builds every API on this type compiles to an
/// empty function, so there is zero runtime cost when the build flag `DEBUG`
/// is not defined.
public enum ScreenNameViewer {

    /// Start tracking and show the overlay. Safe to call multiple times — the
    /// configuration of the most recent call wins. Has no effect in RELEASE.
    @MainActor
    public static func start(_ configure: (inout Configuration) -> Void = { _ in }) {
        #if DEBUG
        var config = Configuration()
        configure(&config)
        Tracker.shared.start(configuration: config)
        #endif
    }

    /// Hide the overlay and stop receiving lifecycle events at the application
    /// level. Method swizzling itself is not undone (no safe way to do so),
    /// but the hook becomes a single boolean check. Has no effect in RELEASE.
    @MainActor
    public static func stop() {
        #if DEBUG
        Tracker.shared.stop()
        #endif
    }
}
