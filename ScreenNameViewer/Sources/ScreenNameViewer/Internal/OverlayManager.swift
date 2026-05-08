#if DEBUG
import UIKit

@MainActor
final class OverlayManager {

    private var overlays: [ObjectIdentifier: SceneOverlay] = [:]
    private var sceneObservers: [ObjectIdentifier: NSObjectProtocol] = [:]

    func update(viewController: UIViewController, configuration: Configuration) {
        guard let scene = viewController.view.window?.windowScene else { return }
        let overlay = ensureOverlay(for: scene, configuration: configuration)
        overlay.updateCurrentViewController(viewController, configuration: configuration)
    }

    func updateRoute(_ name: String?, configuration: Configuration) {
        // SwiftUI's modifier doesn't naturally know which UIWindowScene it
        // belongs to. Apply to every active scene overlay; in single-scene
        // apps this is exactly what's expected, and in multi-scene apps the
        // route name is identical anyway because each scene runs its own
        // SwiftUI graph that drives its own modifier instance.
        for overlay in overlays.values {
            overlay.updateRoute(name, configuration: configuration)
        }
    }

    func syncWithConnectedScenes(configuration: Configuration) {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            let overlay = ensureOverlay(for: windowScene, configuration: configuration)
            if let topVC = topVisibleViewController(in: windowScene) {
                overlay.updateCurrentViewController(topVC, configuration: configuration)
            }
        }
    }

    func refreshAll(configuration: Configuration) {
        for overlay in overlays.values {
            overlay.refresh(configuration: configuration)
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

    private func topVisibleViewController(in scene: UIWindowScene) -> UIViewController? {
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
