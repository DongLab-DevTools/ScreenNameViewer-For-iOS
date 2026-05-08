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

    // 이중 안전장치 — `isUserInteractionEnabled = false`만으로 충분하나 어떠한
    // 터치도 절대 이 윈도우에 도달하지 않도록 hitTest에서도 nil 반환
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
#endif
