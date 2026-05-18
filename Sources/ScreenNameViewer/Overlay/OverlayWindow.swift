#if DEBUG
import UIKit

@MainActor
final class OverlayWindow: UIWindow {

    private let overlayVC = OverlayViewController()

    init(scene: UIWindowScene) {
        super.init(windowScene: scene)
        // `.normal + 1` — 호스트 앱 메인 윈도우 바로 위에만 뜨도록.
        // `.alert + 1` 처럼 너무 높게 두면 iOS 16+ scene 회전 결정에 라이브러리 윈도우가
        // 영향을 끼쳐 호스트의 회전 정책(예: 플레이어 수동 전체화면)이 어긋날 수 있음.
        // 키보드 / 시스템 alert 아래로 깔리는 트레이드오프 — 디버그 라벨이라 허용
        windowLevel = .normal + 1
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
        childDisplay: String?,
        introspectedDisplay: String?,
        routeName: String?,
        configuration: Configuration
    ) {
        overlayVC.update(
            vcDisplay: vcDisplay,
            childDisplay: childDisplay,
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
