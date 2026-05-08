#if DEBUG
import UIKit

@MainActor
final class Tracker {

    static let shared = Tracker()

    private(set) var isRunning = false
    private(set) var configuration = Configuration()

    private let overlays = OverlayManager()

    // 화면에 나타난 순서로 쌓이는 VC 스택 — 가장 최근의 살아있는 항목이
    // 현재 화면. 스택 방식은 부분 가림 모달(페이지 시트, 알럿), 탭 전환,
    // 네비 스택 push/pop을 자연스럽게 처리 — 시트가 닫힐 때 항목이 pop되면
    // 자동으로 그 아래 presenter가 top으로 복원되므로 별도 rescan 불필요
    private var vcStack: [WeakVC] = []

    // SwiftUI `.trackScreenName` 모디파이어가 push한 라우트 항목 스택 —
    // 가장 최근에 등장한 항목의 이름이 표시
    private var routeEntries: [(id: UUID, name: String?)] = []

    // 렌더 합치기 — 모든 외부 변경은 다음 runloop tick에 한 번만 작업 예약.
    // 같은 tick 안에 여러 변경이 들어와도(예: 탭 교체 시 onAppear/
    // onDisappear가 연달아 발생) 한 번의 렌더로 합쳐지므로 오버레이가
    // 중간 "빈 상태"를 노출하지 않음
    private var renderScheduled = false

    private init() {}

    func start(configuration: Configuration) {
        self.configuration = configuration

        if isRunning {
            scheduleRender()
            return
        }
        isRunning = true

        Swizzler.swizzleOnce()

        // 첫 viewDidAppear 사이클이 끝난 뒤에 `start`가 호출된 경우 대비 —
        // 이미 화면에 떠 있는 VC로 스택을 시드
        overlays.ensureOverlaysForConnectedScenes(configuration: configuration)
        for scene in UIApplication.shared.connectedScenes {
            guard let ws = scene as? UIWindowScene,
                  let topVC = OverlayManager.topVisibleViewController(in: ws)
            else { continue }
            push(topVC)
        }
        scheduleRender()
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        vcStack.removeAll()
        routeEntries.removeAll()
        overlays.removeAll()
    }

    func handleViewDidAppear(_ vc: UIViewController) {
        guard isRunning, !(vc is OverlayViewController) else { return }
        push(vc)
        scheduleRender()
    }

    func handleViewDidDisappear(_ vc: UIViewController) {
        guard isRunning, !(vc is OverlayViewController) else { return }
        let id = ObjectIdentifier(vc)
        vcStack.removeAll { $0.id == id || $0.value == nil }
        scheduleRender()
    }

    func setRoute(id: UUID, name: String?) {
        guard isRunning else { return }
        if let idx = routeEntries.firstIndex(where: { $0.id == id }) {
            routeEntries[idx].name = name
        } else {
            routeEntries.append((id, name))
        }
        scheduleRender()
    }

    func removeRoute(id: UUID) {
        guard isRunning else { return }
        routeEntries.removeAll { $0.id == id }
        scheduleRender()
    }

    private func push(_ vc: UIViewController) {
        let id = ObjectIdentifier(vc)
        // top으로 끌어올리기 — 같은 VC의 기존 항목과 이미 해제된 항목을
        // 모두 제거하고 새로 append
        vcStack.removeAll { $0.id == id || $0.value == nil }
        vcStack.append(WeakVC(vc))
    }

    private var currentVC: UIViewController? {
        while let last = vcStack.last {
            if let vc = last.value { return vc }
            vcStack.removeLast()
        }
        return nil
    }

    private var currentRouteName: String? {
        routeEntries.last?.name
    }

    private func scheduleRender() {
        guard !renderScheduled else { return }
        renderScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.renderScheduled = false
            guard self.isRunning else { return }
            self.overlays.render(
                viewController: self.currentVC,
                routeName: self.currentRouteName,
                configuration: self.configuration
            )
        }
    }
}

private struct WeakVC {
    weak var value: UIViewController?
    let id: ObjectIdentifier
    init(_ vc: UIViewController) {
        self.value = vc
        self.id = ObjectIdentifier(vc)
    }
}
#endif
