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
        guard isRunning, !(vc is OverlayViewController) else { return }
        guard Tracker.isScreenLevel(vc) else { return }
        vcStack.push(vc)
        scheduleRender()
    }

    func handleViewDidDisappear(_ vc: UIViewController) {
        guard isRunning, !(vc is OverlayViewController) else { return }
        vcStack.remove(vc)
        scheduleRender()
    }

    /// "화면 단위" VC 판정 — 두 조건 모두 만족해야 화면
    /// 1. 자신이 컨테이너(`UINavigationController` 등) 가 아님 — 컨테이너 자체는 그 안의 visible child 가
    ///    실제 화면이므로 라벨에 적합하지 않음. 사용자 서브클래스 (`BaseNavigationController` 등) 도 차단
    /// 2. `parent` 가 없거나 (window root / modal) 표준 컨테이너 — 일반 VC 안에 박힌 child
    ///    (예: `UIHostingController` 를 임베드한 child VC) 는 부모 화면의 일부일 뿐이므로 제외
    private static func isScreenLevel(_ vc: UIViewController) -> Bool {
        if isContainer(vc) { return false }
        guard let parent = vc.parent else { return true }
        return isContainer(parent)
    }

    private static func isContainer(_ vc: UIViewController) -> Bool {
        vc is UINavigationController
            || vc is UITabBarController
            || vc is UISplitViewController
            || vc is UIPageViewController
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
            let routeName = self.routes.current
            self.overlays.render(
                viewController: self.resolveDisplayVC(routeName: routeName),
                routeName: routeName,
                configuration: self.configuration
            )
        }
    }

    /// 표시할 VC 결정:
    /// - route 가 설정된 상태(push 등 깊이 들어간 상태): top VC 만 사용. 그 밑으로 내려가면
    ///   잘못된 outer 화면(예: 루트 ContentView)이 노출되어 사용자 혼동.
    /// - route 없음(루트): top 이 표시 가능한 이름을 못 주면 스택을 내려가며 이름이 나오는
    ///   첫 VC 사용. 예: 루트에 SwiftUI NavigationStack 두면 top 이 SwiftUI 내부 호스트라
    ///   이름 못 주는데, 그 밑의 외곽 UIHostingController 의 introspection 으로 ContentView 노출.
    private func resolveDisplayVC(routeName: String?) -> UIViewController? {
        if routeName != nil {
            return vcStack.top
        }
        return vcStack.topMatching { vc in
            VCNameFormatter.names(for: vc) != nil
                || SwiftUIIntrospection.extractRootName(from: vc) != nil
        } ?? vcStack.top
    }
}
#endif
