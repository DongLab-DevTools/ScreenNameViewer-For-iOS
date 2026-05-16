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

    func update(
        vcDisplay: String?,
        introspectedDisplay: String?,
        routeName: String?,
        configuration: Configuration
    ) {
        overlayVC.update(
            vcDisplay: vcDisplay,
            introspectedDisplay: introspectedDisplay,
            routeName: routeName,
            configuration: configuration
        )
    }

    /// 오버레이 윈도우 좌표의 탭 위치를 OverlayViewController에 전달
    /// - OverlayManager가 앱 윈도우 제스처에서 받은 탭을 여기로 라우팅
    func handlePotentialLabelTap(at point: CGPoint) {
        overlayVC.handlePotentialLabelTap(at: point)
    }

    // 모든 터치 통과 — 라벨 탭은 별도로 앱 윈도우 제스처가 인식
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
#endif
