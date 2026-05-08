#if DEBUG
import UIKit

@MainActor
final class SceneOverlay {

    private weak var scene: UIWindowScene?
    private var window: OverlayWindow?

    init(scene: UIWindowScene, configuration: Configuration) {
        self.scene = scene
        let window = OverlayWindow(scene: scene)
        self.window = window
        window.isHidden = false
    }

    func update(viewController: UIViewController?, routeName: String?, configuration: Configuration) {
        let vcName = viewController.flatMap { VCNameFormatter.displayName(for: $0) }
        window?.update(
            viewControllerName: vcName,
            routeName: routeName,
            configuration: configuration
        )
    }

    func tearDown() {
        window?.isHidden = true
        window = nil
    }
}
#endif
