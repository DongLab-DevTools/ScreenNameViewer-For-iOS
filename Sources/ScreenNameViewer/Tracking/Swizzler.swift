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

    // 메서드 교환 후, 아래의 재귀처럼 보이는 호출이 사실 원본 viewDidAppear/Disappear 호출
    // UIViewController가 `@MainActor`라 이 extension도 isolation 상속 → Tracker 직접 호출 가능
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
