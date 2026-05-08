#if DEBUG
import UIKit

@MainActor
final class Tracker {

    static let shared = Tracker()

    private(set) var isRunning = false
    private(set) var configuration = Configuration()

    private let overlays = OverlayManager()

    // Active VCs in appearance order. The most recent live entry is the
    // current "screen". A stack-based approach naturally handles partial-cover
    // modals (page sheets, alerts), tab switches, and nav-stack pushes/pops:
    // when a sheet's content disappears we pop it and the presenter is back
    // on top automatically — no rescan needed.
    private var vcStack: [WeakVC] = []

    // Stack of route entries pushed by SwiftUI .trackScreenName modifiers.
    // The most recently appeared entry wins.
    private var routeEntries: [(id: UUID, name: String?)] = []

    // Render coalescing: every public mutation only schedules work for the
    // next runloop tick. Multiple changes in the same tick (e.g. a tab swap
    // firing onAppear+onDisappear back-to-back) collapse into one render, so
    // the overlay never shows an intermediate "empty" state.
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

        // Seed the vc stack with whatever is already on screen, in case
        // `start` was called after the first viewDidAppear cycle finished.
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
        // Move-to-top: drop any prior entry for this VC plus any deallocated
        // entries, then append.
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
