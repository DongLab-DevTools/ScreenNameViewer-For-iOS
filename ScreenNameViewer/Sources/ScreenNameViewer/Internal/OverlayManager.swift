#if DEBUG
import UIKit

@MainActor
final class OverlayManager {

    private var overlays: [ObjectIdentifier: SceneOverlay] = [:]
    private var sceneObservers: [ObjectIdentifier: NSObjectProtocol] = [:]

    /// Apply the current state (vc + route) to every connected scene's overlay.
    /// In single-scene apps this is the only scene; in multi-scene apps the
    /// vc/route values are global and applied uniformly — good enough for the
    /// 99% case, and unambiguous for the rare iPad split-window setups.
    func render(
        viewController: UIViewController?,
        routeName: String?,
        configuration: Configuration
    ) {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            let overlay = ensureOverlay(for: windowScene, configuration: configuration)
            overlay.update(
                viewController: viewController,
                routeName: routeName,
                configuration: configuration
            )
        }
    }

    func ensureOverlaysForConnectedScenes(configuration: Configuration) {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            _ = ensureOverlay(for: windowScene, configuration: configuration)
        }
    }

    func removeAll() {
        for (key, observer) in sceneObservers {
            NotificationCenter.default.removeObserver(observer)
            sceneObservers[key] = nil
        }
        for overlay in overlays.values {
            overlay.tearDown()
        }
        overlays.removeAll()
    }

    private func ensureOverlay(for scene: UIWindowScene, configuration: Configuration) -> SceneOverlay {
        let key = ObjectIdentifier(scene)
        if let existing = overlays[key] { return existing }

        let overlay = SceneOverlay(scene: scene, configuration: configuration)
        overlays[key] = overlay

        let observer = NotificationCenter.default.addObserver(
            forName: UIScene.didDisconnectNotification,
            object: scene,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.overlays[key]?.tearDown()
                self.overlays[key] = nil
                if let observer = self.sceneObservers[key] {
                    NotificationCenter.default.removeObserver(observer)
                    self.sceneObservers[key] = nil
                }
            }
        }
        sceneObservers[key] = observer

        return overlay
    }

    /// Best-effort walk to find what's currently on screen. Used to seed the
    /// tracker when `start()` is called after the first viewDidAppear cycle.
    static func topVisibleViewController(in scene: UIWindowScene) -> UIViewController? {
        let candidate = scene.windows.first(where: \.isKeyWindow) ?? scene.windows.first
        return candidate?.rootViewController?._snv_topMostViewController
    }
}

private extension UIViewController {

    var _snv_topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented._snv_topMostViewController
        }
        if let nav = self as? UINavigationController, let visible = nav.visibleViewController {
            return visible._snv_topMostViewController
        }
        if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
            return selected._snv_topMostViewController
        }
        return self
    }
}
#endif
