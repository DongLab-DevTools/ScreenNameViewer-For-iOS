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
        let labels = viewController.map(resolveLabels(for:)) ?? Labels()
        window?.update(
            vcDisplay: labels.vcDisplay,
            vcFull: labels.vcFull,
            introspectedDisplay: labels.introspectedDisplay,
            introspectedFull: labels.introspectedFull,
            routeName: routeName,
            configuration: configuration
        )
    }

    private struct Labels {
        var vcDisplay: String?
        var vcFull: String?
        var introspectedDisplay: String?
        var introspectedFull: String?
    }

    /// 좌측 라벨 결정 — 두 라벨이 독립적으로 표시 여부 결정
    /// - vcLabel: VCNameFormatter 가 검색 가능한 사용자 클래스명을 줄 때만
    /// - introspectedLabel: SwiftUIIntrospection 이 안쪽 사용자 View 타입을 캐낼 때만
    /// 라이브러리 정책: 표시되는 모든 라벨 텍스트는 사용자 프로젝트에서 grep 가능해야 함
    private func resolveLabels(for vc: UIViewController) -> Labels {
        var labels = Labels()
        if let names = VCNameFormatter.names(for: vc) {
            labels.vcDisplay = names.display
            labels.vcFull = names.full
        }
        if let introspected = SwiftUIIntrospection.extractRootName(from: vc) {
            labels.introspectedDisplay = introspected.display
            // long-press 토스트로 fully-qualified 원본 타입 노출 (디버깅용)
            labels.introspectedFull = introspected.source
        }
        return labels
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
