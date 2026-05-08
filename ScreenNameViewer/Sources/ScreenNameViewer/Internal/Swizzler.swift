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
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController._snv_swizzled_viewDidAppear(_:))

        guard
            let originalMethod = class_getInstanceMethod(cls, originalSelector),
            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
        else {
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIViewController {

    // After `method_exchangeImplementations`, calling this selector executes
    // the original `viewDidAppear(_:)` implementation, and calling the
    // original selector executes this body. The recursive-looking call below
    // is therefore the call to the original method.
    @objc dynamic func _snv_swizzled_viewDidAppear(_ animated: Bool) {
        self._snv_swizzled_viewDidAppear(animated)

        MainActor.assumeIsolated {
            Tracker.shared.handleViewDidAppear(self)
        }
    }
}
#endif
