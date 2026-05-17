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

    /// Tracker 가 미리 계산해 넘긴 라벨을 그대로 오버레이 윈도우에 전달
    /// — 라벨 결정 로직 (VCNameFormatter / SwiftUIIntrospection / child 탐색) 은 Tracker 측에서 한 번만 수행
    func update(
        vcDisplay: String?,
        childDisplay: String?,
        introspectedDisplay: String?,
        routeName: String?,
        configuration: Configuration
    ) {
        window?.update(
            vcDisplay: vcDisplay,
            childDisplay: childDisplay,
            introspectedDisplay: introspectedDisplay,
            routeName: routeName,
            configuration: configuration
        )
    }

    /// 앱 윈도우 좌표의 탭 위치를 받아 라벨 영역인지 검사 후 토스트 표시
    func handlePotentialLabelTap(at point: CGPoint, fromWindow appWindow: UIWindow) {
        guard let overlayWindow = window else { return }
        let overlayPoint = appWindow.convert(point, to: overlayWindow)
        overlayWindow.handlePotentialLabelTap(at: overlayPoint)
    }

    func tearDown() {
        window?.isHidden = true
        window = nil
    }
}
#endif
