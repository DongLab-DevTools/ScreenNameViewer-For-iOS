#if DEBUG
import UIKit

/// `UIViewController`를 오버레이 표시용 이름으로 변환
///
/// 계약: 표시되는 이름은 모두 사용자 코드베이스에서 grep 가능한 심볼
/// Apple framework 의 클래스 (`UIHostingController`, `UISystemKeyboardDockController`,
/// `NavigationStackHostingController` 등) 는 nil 반환 → vc 라벨 자동 미표시
/// SwiftUI 화면은 `SwiftUIIntrospection` 또는 `.trackScreenName(...)` 이 이름 제공
enum VCNameFormatter {

    /// `display`: 라벨용 짧은 이름
    /// `full`: 토스트용 풀네임 (모듈 프리픽스 + 제너릭 포함)
    struct Names {
        let display: String
        let full: String
    }

    static func names(for vc: UIViewController) -> Names? {
        // Apple framework 클래스(공개 / 비공개) 는 사용자 코드 심볼이 아니므로 라벨 부적합
        // - UIKit base (UIHostingController, UISystemKeyboardDockController, UIAlertController, ...)
        // - SwiftUI 내부 호스트 (NavigationStackHostingController, PresentationHostingController, ...)
        // bundleIdentifier 가 `com.apple.` prefix 면 framework 클래스
        if FrameworkModules.isAppleFrameworkClass(type(of: vc)) {
            return nil
        }

        let raw = String(describing: type(of: vc))
        var short = raw

        // `UIHostingController<NavigationStack<…>>` → `UIHostingController`
        // (Apple 클래스는 위에서 이미 걸렸지만, 사용자 generic 서브클래스 대비)
        if let lt = short.firstIndex(of: "<") {
            short = String(short[..<lt])
        }

        // `MyApp.HomeViewController` → `HomeViewController`
        if let dot = short.lastIndex(of: ".") {
            short = String(short[short.index(after: dot)...])
        }

        if short.isEmpty {
            return nil
        }
        return Names(display: short, full: raw)
    }
}
#endif
