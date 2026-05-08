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
        let vcNames = viewController.flatMap { VCNameFormatter.names(for: $0) }
        window?.update(
            vcDisplay: vcNames?.display,
            vcFull: vcNames?.full,
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
