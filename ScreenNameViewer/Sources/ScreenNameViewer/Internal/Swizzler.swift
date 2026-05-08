#if DEBUG
import UIKit
import ObjectiveC.runtime

enum Swizzler {

    private static var didSwizzle = false

    @MainActor
    static func swizzleOnce() {
        guard !didSwizzle else { return }
        didSwizzle = true

        let cls: AnyClass = UIViewController.self
        exchange(
            cls,
            original: #selector(UIViewController.viewDidAppear(_:)),
            with: #selector(UIViewController._snv_swizzled_viewDidAppear(_:))
        )
        exchange(
            cls,
            original: #selector(UIViewController.viewDidDisappear(_:)),
            with: #selector(UIViewController._snv_swizzled_viewDidDisappear(_:))
        )
    }

    private static func exchange(_ cls: AnyClass, original: Selector, with swizzled: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(cls, original),
            let swizzledMethod = class_getInstanceMethod(cls, swizzled)
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIViewController {

    // After `method_exchangeImplementations`, calling these selectors executes
    // the original UIKit implementations, and calling the originals executes
    // these bodies. The recursive-looking calls below are therefore the calls
    // to the original methods.

    // UIViewController is `@MainActor` in modern UIKit headers, so these
    // extension methods inherit main-actor isolation; calls to the
    // `@MainActor` Tracker compile without an explicit isolation guard.
    @objc dynamic func _snv_swizzled_viewDidAppear(_ animated: Bool) {
        self._snv_swizzled_viewDidAppear(animated)
        Tracker.shared.handleViewDidAppear(self)
    }

    @objc dynamic func _snv_swizzled_viewDidDisappear(_ animated: Bool) {
        self._snv_swizzled_viewDidDisappear(animated)
        Tracker.shared.handleViewDidDisappear(self)
    }
}
#endif
