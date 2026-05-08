#if DEBUG
import UIKit

@MainActor
final class OverlayManager: NSObject, UIGestureRecognizerDelegate {

    private var overlays: [ObjectIdentifier: SceneOverlay] = [:]
    private var sceneObservers: [ObjectIdentifier: NSObjectProtocol] = [:]
    private let instrumentedWindows = NSHashTable<UIWindow>.weakObjects()

    override init() {
        super.init()
    }

    /// 현재 상태(vc + route)를 연결된 모든 씬의 오버레이에 적용. 단일 씬
    /// 앱에서는 그 한 씬만 갱신 대상, 멀티 씬 앱에서는 동일한 vc/route 값을
    /// 모든 씬에 일괄 적용 — 99% 케이스 깔끔 커버 + iPad의 드문 split-window
    /// 상황에서도 결과 명확
    func render(
        viewController: UIViewController?,
        routeName: String?,
        configuration: Configuration
    ) {
        // 라벨 탭으로 토스트 표시를 위한 제스처를 앱의 실제 윈도우에 설치 —
        // `cancelsTouchesInView = false` + 동시 인식 허용 덕분에 아래 버튼/
        // 컨트롤은 평소처럼 정상 동작
        if let appWindow = viewController?.view.window, !(appWindow is OverlayWindow) {
            ensureTapGesture(on: appWindow)
        }

        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            let overlay = ensureOverlay(for: windowScene, configuration: configuration)
            overlay.update(
                viewController: viewController,
                routeName: routeName,
                configuration: configuration
            )
        }
    }

    func ensureOverlaysForConnectedScenes(configuration: Configuration) {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            _ = ensureOverlay(for: windowScene, configuration: configuration)
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
            // notification 클로저는 isolation 부재 — `@MainActor` 상태 접근
            // 전 MainActor 진입 필요. 씬 disconnect 정리 작업이라 약간의
            // async 지연 무관
            Task { @MainActor [weak self] in
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

    private func ensureTapGesture(on window: UIWindow) {
        guard !instrumentedWindows.contains(window) else { return }
        instrumentedWindows.add(window)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAppWindowTap(_:)))
        // 핵심 — 탭 인식은 하되 아래 버튼/컨트롤로 가는 터치는 막지 않기
        tap.cancelsTouchesInView = false
        tap.delaysTouchesBegan = false
        tap.delaysTouchesEnded = false
        tap.delegate = self
        window.addGestureRecognizer(tap)
    }

    @objc private func handleAppWindowTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended,
              let appWindow = gesture.view as? UIWindow,
              let scene = appWindow.windowScene
        else { return }

        let key = ObjectIdentifier(scene)
        guard let overlay = overlays[key] else { return }

        let location = gesture.location(in: appWindow)
        overlay.handlePotentialLabelTap(at: location, fromWindow: appWindow)
    }

    nonisolated func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        // 앱이 가진 모든 제스처(버튼, 스크롤, SwiftUI gesture 등)와 나란히
        // 인식 — 우리 탭 인식이 다른 제스처의 진행을 절대 방해하지 않음
        return true
    }

    /// 현재 화면 최상단 항목 best-effort 탐색. 첫 viewDidAppear 사이클 종료
    /// 후 `start()` 호출 시 트래커 시드 용도
    static func topVisibleViewController(in scene: UIWindowScene) -> UIViewController? {
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
