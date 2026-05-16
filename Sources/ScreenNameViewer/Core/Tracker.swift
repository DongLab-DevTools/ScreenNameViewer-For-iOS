#if DEBUG
import UIKit

/// 라이브러리 코디네이터
///
/// 상태는 `VCStack` / `RouteRegistry`가, 렌더 합치기는 `RenderScheduler`가, 표시는 `OverlayManager`가 담당
/// 본 클래스는 라이프사이클 이벤트를 받아 각 컴포넌트로 위임만
@MainActor
final class Tracker {

    static let shared = Tracker()

    private(set) var isRunning = false
    private(set) var configuration = Configuration()

    private let overlays = OverlayManager()
    private var vcStack = VCStack()
    private var routes = RouteRegistry()
    private let renderScheduler = RenderScheduler()

    private init() {}

    func start(configuration: Configuration) {
        self.configuration = configuration

        if isRunning {
            scheduleRender()
            return
        }
        isRunning = true

        Swizzler.swizzleOnce()

        // 첫 viewDidAppear 사이클 종료 후 `start` 호출 케이스 대비
        // 이미 화면에 떠 있는 VC로 스택 시드
        overlays.ensureOverlaysForConnectedScenes(configuration: configuration)
        for scene in UIApplication.shared.connectedScenes {
            guard let ws = scene as? UIWindowScene,
                  let topVC = OverlayManager.topVisibleViewController(in: ws)
            else { continue }
            vcStack.push(topVC)
        }
        scheduleRender()
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        vcStack.clear()
        routes.clear()
        overlays.removeAll()
    }

    func handleViewDidAppear(_ vc: UIViewController) {
        guard isRunning, !(vc is OverlayViewController), !isExcluded(vc) else { return }
        vcStack.push(vc)
        scheduleRender()
    }

    func handleViewDidDisappear(_ vc: UIViewController) {
        guard isRunning, !(vc is OverlayViewController), !isExcluded(vc) else { return }
        vcStack.remove(vc)
        scheduleRender()
    }

    private func isExcluded(_ vc: UIViewController) -> Bool {
        guard !configuration.excludedClassNames.isEmpty else { return false }
        return configuration.excludedClassNames.contains(VCNameFormatter.shortName(for: vc))
    }

    func setRoute(id: UUID, name: String?) {
        guard isRunning else { return }
        routes.set(id: id, name: name)
        scheduleRender()
    }

    func removeRoute(id: UUID) {
        guard isRunning else { return }
        routes.remove(id: id)
        scheduleRender()
    }

    private func scheduleRender() {
        renderScheduler.schedule { [weak self] in
            guard let self, self.isRunning else { return }
            self.overlays.render(
                viewController: self.resolveDisplayVC(),
                routeName: self.routes.current,
                configuration: self.configuration
            )
        }
    }

    /// 라벨 표시용 VC 결정 — 위에서부터 내려가며 `VCNameFormatter`가 이름을 뽑아주는 첫 VC 사용
    /// 모두 익명(예: SwiftUI 내부 호스트만 쌓인 상태)이면 `top`을 그대로 돌려줘 기존 동작 유지
    private func resolveDisplayVC() -> UIViewController? {
        vcStack.topMatching { VCNameFormatter.names(for: $0) != nil } ?? vcStack.top
    }
}
#endif
