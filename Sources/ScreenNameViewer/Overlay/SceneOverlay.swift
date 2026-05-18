#if DEBUG
import UIKit

/// scene 당 1개. 호스트 keyWindow 를 추적해서 그 위에 `OverlayView` 를 직접 박는다
///
/// 별도 `UIWindow` 미사용 — 라이브러리 윈도우가 존재하면 iOS multi-window 회전 결정에
/// 끼어들어 호스트 회전 정책이 어긋날 수 있어, 회전 정책 격리를 위해 호스트 윈도우에 직접 주입
@MainActor
final class SceneOverlay {

    private weak var scene: UIWindowScene?
    private let overlayView = OverlayView()
    private weak var attachedWindow: UIWindow?
    private var keyWindowObserver: NSObjectProtocol?

    init(scene: UIWindowScene, configuration: Configuration) {
        self.scene = scene
        attachToHostKeyWindow()

        // 호스트가 keyWindow 를 교체하는 케이스(드물지만 가능) 대응 — 노티 받아 옮김
        keyWindowObserver = NotificationCenter.default.addObserver(
            forName: UIWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard let newKey = note.object as? UIWindow,
                      newKey.windowScene === self.scene,
                      newKey !== self.attachedWindow
                else { return }
                self.attachToHostKeyWindow()
            }
        }
    }

    /// 라벨 view 를 host keyWindow 의 가장 위로 끌어올림 — 매 update 마다 호출해 모달/시트
    /// 가 떴을 때 라벨이 그 아래로 가려지지 않도록 보장. host window 의 직접 subview 만 영향 받음
    /// (presentedViewController 의 view 는 별도 layer 라 z-order 경쟁 대상 아님)
    func update(
        vcDisplay: String?,
        childDisplay: String?,
        introspectedDisplay: String?,
        routeName: String?,
        configuration: Configuration
    ) {
        if let window = attachedWindow {
            window.bringSubviewToFront(overlayView)
        } else {
            attachToHostKeyWindow()
        }
        overlayView.update(
            vcDisplay: vcDisplay,
            childDisplay: childDisplay,
            introspectedDisplay: introspectedDisplay,
            routeName: routeName,
            configuration: configuration
        )
    }

    /// 앱 윈도우 좌표의 탭 위치를 받아 라벨 영역인지 검사 후 토스트 표시
    func handlePotentialLabelTap(at point: CGPoint, fromWindow appWindow: UIWindow) {
        // overlayView 는 host window 의 subview 라 좌표계 동일
        overlayView.handlePotentialLabelTap(at: point)
    }

    func tearDown() {
        if let observer = keyWindowObserver {
            NotificationCenter.default.removeObserver(observer)
            keyWindowObserver = nil
        }
        overlayView.removeFromSuperview()
        attachedWindow = nil
    }

    private func attachToHostKeyWindow() {
        guard let scene else { return }
        // scene 의 keyWindow 우선, 없으면 첫 윈도우
        let hostWindow = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
        guard let hostWindow else { return }
        if hostWindow === attachedWindow, overlayView.superview === hostWindow {
            return
        }
        overlayView.removeFromSuperview()
        hostWindow.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: hostWindow.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: hostWindow.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: hostWindow.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: hostWindow.bottomAnchor),
        ])
        attachedWindow = hostWindow
    }
}
#endif
