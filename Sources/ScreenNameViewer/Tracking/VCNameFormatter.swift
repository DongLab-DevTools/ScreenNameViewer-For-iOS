#if DEBUG
import UIKit

/// `UIViewController`를 오버레이 표시용 이름으로 변환
///
/// 계약: 표시되는 이름은 모두 사용자 코드베이스에서 grep 가능한 심볼
/// Apple framework 의 클래스 (`UIHostingController`, `UISystemKeyboardDockController`,
/// `NavigationStackHostingController` 등) 는 nil 반환 → vc 라벨 자동 미표시
/// SwiftUI 화면은 `SwiftUIIntrospection` 또는 `.trackScreenName(...)` 이 이름 제공
enum VCNameFormatter {

    /// 라벨용 짧은 이름. Apple framework 클래스는 nil
    static func displayName(for vc: UIViewController) -> String? {
        // Apple framework 클래스(공개 / 비공개) 는 사용자 코드 심볼이 아니므로 라벨 부적합
        if FrameworkModules.isAppleFrameworkClass(type(of: vc)) {
            return nil
        }

        var short = String(describing: type(of: vc))

        // `UIHostingController<NavigationStack<…>>` → `UIHostingController`
        // (Apple 클래스는 위에서 이미 걸렸지만, 사용자 generic 서브클래스 대비)
        if let lt = short.firstIndex(of: "<") {
            short = String(short[..<lt])
        }

        // `MyApp.HomeViewController` → `HomeViewController`
        if let dot = short.lastIndex(of: ".") {
            short = String(short[short.index(after: dot)...])
        }

        return short.isEmpty ? nil : short
    }
}
#endif
