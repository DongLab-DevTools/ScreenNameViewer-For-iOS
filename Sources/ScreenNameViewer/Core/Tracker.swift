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
    // 테스트에서 push/remove 결과 검증 위해 internal — 외부 모듈에 노출되지는 않음
    var vcStack = VCStack()
    var routes = RouteRegistry()
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

    /// "화면 단위" VC 판정 — 세 조건 모두 만족해야 화면
    /// 1. 자신이 컨테이너(`UINavigationController` 등) 가 아님 — 컨테이너 자체는 그 안의 visible child 가
    ///    실제 화면이므로 라벨에 적합하지 않음. 사용자 서브클래스 (`BaseNavigationController` 등) 도 차단
    /// 2. `parent` 가 없거나 (window root / modal) 표준 컨테이너 — 일반 VC 안에 박힌 child
    ///    (예: `UIHostingController` 를 임베드한 child VC) 는 부모 화면의 일부일 뿐이므로 제외
    /// 3. `parent` 가 없는데 자신이 Apple framework class (`UIHostingController` 등) 면 셀/뷰 안에
    ///    `addChild` 없이 임베드된 host 일 가능성이 큼 — 화면 단위로 보지 않음
    static func isScreenLevel(_ vc: UIViewController) -> Bool {
        if isContainer(vc) { return false }
        guard let parent = vc.parent else {
            // 회귀: VaLineCell 처럼 셀이 UIHostingController 를 contentView 에만 add 하는 케이스 —
            // host.viewDidAppear 가 호출되어도 push 되지 않도록 차단
            return !FrameworkModules.isAppleFrameworkClass(type(of: vc))
        }
        return isContainer(parent)
    }

    static func isContainer(_ vc: UIViewController) -> Bool {
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
            let snapshot = self.resolveDisplay(routeName: routeName)
            self.overlays.render(
                snapshot: snapshot,
                routeName: routeName,
                configuration: self.configuration
            )
        }
    }

    /// 라벨 한 세트 분량의 계산 결과 — 한 render 사이클에서 한 번만 계산해 모든 scene 의 오버레이에 공유
    struct DisplaySnapshot {
        let viewController: UIViewController?
        let vcDisplay: String?
        let childDisplay: String?
        let introspectedDisplay: String?

        static let empty = DisplaySnapshot(
            viewController: nil,
            vcDisplay: nil,
            childDisplay: nil,
            introspectedDisplay: nil
        )
    }

    /// 표시할 VC + 그 VC 의 라벨 텍스트들을 결정:
    /// - route 가 설정된 상태(push 등 깊이 들어간 상태): top VC 만 사용. 그 밑으로 내려가면
    ///   잘못된 outer 화면(예: 루트 ContentView)이 노출되어 사용자 혼동.
    /// - route 없음(루트): top 이 표시 가능한 이름을 못 주면 스택을 내려가며 이름이 나오는
    ///   첫 VC 사용. 예: 루트에 SwiftUI NavigationStack 두면 top 이 SwiftUI 내부 호스트라
    ///   이름 못 주는데, 그 밑의 외곽 UIHostingController 의 introspection 으로 ContentView 노출.
    ///
    /// snapshot 으로 라벨 값을 미리 담아 반환 — SceneOverlay 가 매 scene 마다 재계산하는 비용 제거
    func resolveDisplay(routeName: String?) -> DisplaySnapshot {
        if routeName != nil {
            guard let top = vcStack.top else { return .empty }
            return makeSnapshot(for: top)
        }
        if let named = vcStack.topMap({ makeNamedSnapshot(for: $0) }) {
            return named
        }
        guard let top = vcStack.top else { return .empty }
        return makeSnapshot(for: top)
    }

    private func makeSnapshot(for topVC: UIViewController) -> DisplaySnapshot {
        // top 이 Apple framework (e.g. UIViewControllerRepresentable 의 내부 host) 면 children 을
        // 따라 내려가 첫 사용자 코드 VC ("user root") 까지 도달. vcDisplay 는 그 user root 기준
        let userRoot = findUserRoot(in: topVC) ?? topVC
        let userRootName = VCNameFormatter.displayName(for: userRoot)
        return DisplaySnapshot(
            viewController: topVC,
            vcDisplay: userRootName,
            childDisplay: visibleChildDisplay(of: userRoot, excluding: userRootName),
            introspectedDisplay: SwiftUIIntrospection.extractRootName(from: topVC)
        )
    }

    private func makeNamedSnapshot(for vc: UIViewController) -> DisplaySnapshot? {
        let snap = makeSnapshot(for: vc)
        return (snap.vcDisplay != nil || snap.childDisplay != nil || snap.introspectedDisplay != nil) ? snap : nil
    }

    /// VC 자신이 user 코드면 그대로, 아니면 visible children 을 깊이 따라가며 첫 user code VC 반환
    /// 예: UIViewControllerRepresentable 의 SwiftUI 내부 host → 그 안의 사용자 VC
    func findUserRoot(in vc: UIViewController) -> UIViewController? {
        if VCNameFormatter.displayName(for: vc) != nil {
            return vc
        }
        for child in vc.children {
            guard child.viewIfLoaded?.window != nil else { continue }
            if let found = findUserRoot(in: child) {
                return found
            }
        }
        return nil
    }

    /// `parent` 안에 떠 있는 visible child 중 첫 사용자 코드 VC 이름
    /// Apple framework child 는 한 단계 더 내려가 그 안의 user code VC 찾기 시도
    /// 부모 자신 이름과 중복은 무시
    func visibleChildDisplay(of parent: UIViewController, excluding excludedName: String?) -> String? {
        for child in parent.children {
            guard child.viewIfLoaded?.window != nil else { continue }
            if let name = VCNameFormatter.displayName(for: child), name != excludedName {
                return name
            }
            if let name = visibleChildDisplay(of: child, excluding: excludedName) {
                return name
            }
        }
        return nil
    }
}
#endif
