#if DEBUG
import UIKit

@MainActor
final class SceneOverlay {

    private weak var scene: UIWindowScene?
    private var window: OverlayWindow?

    private weak var currentVC: UIViewController?
    private var currentRoute: String?

    init(scene: UIWindowScene, configuration: Configuration) {
        self.scene = scene
        let window = OverlayWindow(scene: scene)
        self.window = window
        window.isHidden = false
    }

    func updateCurrentViewController(_ vc: UIViewController, configuration: Configuration) {
        currentVC = vc
        render(configuration: configuration)
    }

    func updateRoute(_ name: String?, configuration: Configuration) {
        currentRoute = name
        render(configuration: configuration)
    }

    func refresh(configuration: Configuration) {
        render(configuration: configuration)
    }

    func tearDown() {
        window?.isHidden = true
        window = nil
    }

    private func render(configuration: Configuration) {
        let vcName = currentVC.map { String(describing: type(of: $0)) }
        window?.update(
            viewControllerName: vcName,
            routeName: currentRoute,
            configuration: configuration
        )
    }
}
#endif
