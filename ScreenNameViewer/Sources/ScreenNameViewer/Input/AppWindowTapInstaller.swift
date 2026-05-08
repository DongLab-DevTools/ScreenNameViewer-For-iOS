#if DEBUG
import UIKit

/// 앱의 실제 윈도우에 `cancelsTouchesInView = false` UITapGestureRecognizer 설치
///
/// 라벨 영역 탭을 토스트로 라우팅, 아래의 버튼/컨트롤/SwiftUI 제스처는 차단 X
/// 윈도우 1개당 한 번만 설치 (약한 참조 셋 추적, 윈도우 해제 시 자동 정리)
/// 인식한 탭 위치는 `onTap` 클로저로 OverlayManager에 전달
@MainActor
final class AppWindowTapInstaller: NSObject, UIGestureRecognizerDelegate {

    var onTap: ((CGPoint, UIWindow) -> Void)?

    private let instrumented = NSHashTable<UIWindow>.weakObjects()

    override init() {
        super.init()
    }

    func installIfNeeded(on window: UIWindow) {
        guard !instrumented.contains(window) else { return }
        instrumented.add(window)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        // 핵심 — 탭 인식만 하고 아래 view로 가는 터치는 절대 막지 않음
        tap.cancelsTouchesInView = false
        tap.delaysTouchesBegan = false
        tap.delaysTouchesEnded = false
        tap.delegate = self
        window.addGestureRecognizer(tap)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended,
              let window = gesture.view as? UIWindow
        else { return }
        onTap?(gesture.location(in: window), window)
    }

    nonisolated func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        // 앱이 가진 모든 제스처(버튼, 스크롤, SwiftUI gesture 등)와 나란히
        // 인식 — 다른 제스처의 진행 절대 방해 X
        return true
    }
}
#endif
