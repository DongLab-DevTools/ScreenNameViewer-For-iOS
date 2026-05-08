#if DEBUG
import UIKit

@MainActor
final class OverlayWindow: UIWindow {

    private let overlayVC = OverlayViewController()

    init(scene: UIWindowScene) {
        super.init(windowScene: scene)
        windowLevel = .alert + 1
        isUserInteractionEnabled = false
        backgroundColor = .clear
        rootViewController = overlayVC
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func update(viewControllerName: String?, routeName: String?, configuration: Configuration) {
        overlayVC.update(
            viewControllerName: viewControllerName,
            routeName: routeName,
            configuration: configuration
        )
    }

    // Belt-and-suspenders: even though `isUserInteractionEnabled` is false,
    // make absolutely sure no touch ever lands here.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
#endif
