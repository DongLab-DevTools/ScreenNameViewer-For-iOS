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

    // `method_exchangeImplementations` 이후 — 이 셀렉터 호출 시 원본 UIKit
    // 구현 실행, 원본 셀렉터 호출 시 아래 본문 실행. 따라서 아래의 재귀처럼
    // 보이는 호출이 사실상 원본 메서드 호출

    // UIViewController는 모던 UIKit 헤더에서 이미 `@MainActor` 어노테이션
    // — 이 extension 메서드도 main-actor isolation 묵시적 상속, 별도 isolation
    // 가드 없이 `@MainActor` Tracker 직접 호출 가능
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
