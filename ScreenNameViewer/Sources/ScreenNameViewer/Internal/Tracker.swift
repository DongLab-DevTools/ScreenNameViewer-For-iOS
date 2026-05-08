#if DEBUG
import UIKit

@MainActor
final class Tracker {

    static let shared = Tracker()

    private(set) var isRunning = false
    private(set) var configuration = Configuration()

    private let overlays = OverlayManager()

    private init() {}

    func start(configuration: Configuration) {
        self.configuration = configuration

        if isRunning {
            overlays.refreshAll(configuration: configuration)
            return
        }
        isRunning = true

        Swizzler.swizzleOnce()
        overlays.syncWithConnectedScenes(configuration: configuration)
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        overlays.removeAll()
    }

    func handleViewDidAppear(_ vc: UIViewController) {
        guard isRunning else { return }
        // Skip our own overlay's hosting VC so we don't recursively render it.
        if vc is OverlayViewController { return }
        overlays.update(viewController: vc, configuration: configuration)
    }

    func updateRoute(_ name: String?) {
        guard isRunning else { return }
        overlays.updateRoute(name, configuration: configuration)
    }
}
#endif
