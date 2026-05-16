#if DEBUG
import UIKit

/// `UIViewController`를 오버레이 표시용 이름으로 변환
///
/// 계약: 표시되는 이름은 모두 사용자 코드베이스에서 grep 가능한 심볼
/// 프레임워크 베이스 클래스(예: `UIHostingController<...>`)는 nil 반환 → vc 라벨 자동 미표시
/// SwiftUI 화면은 `.trackScreenName(...)`이 라우트 이름 제공 전제
enum VCNameFormatter {

    /// 사용자 코드에서 grep 가능한 심볼이 아닌 framework base / SwiftUI internal 클래스명들.
    /// `String(describing: type(of: vc))` 의 모듈 prefix·제너릭 제거 후 짧은 이름이 여기 매칭되면
    /// vc 라벨 노출 안 함 (라이브러리 정책: 표시되는 라벨은 항상 프로젝트 코드에서 찾을 수 있어야 함)
    private static let frameworkBaseClasses: Set<String> = [
        // UIKit base classes
        "UIViewController",
        "UINavigationController",
        "UITabBarController",
        "UISplitViewController",
        "UIPageViewController",
        "UIHostingController",
        "UIAlertController",
        "UIActivityViewController",
        "UIDocumentPickerViewController",
        "UIImagePickerController",
        "UISearchController",
        // SwiftUI internal hosts — 사용자 프로젝트에서 검색해도 못 찾는 SwiftUI 내부 클래스
        "NavigationStackHostingController",
        "PresentationHostingController",
        "UIKitNavigationController",
    ]

    /// `display`: 라벨용 짧은 이름
    /// `full`: 토스트용 풀네임 (모듈 프리픽스 + 제너릭 포함)
    struct Names {
        let display: String
        let full: String
    }

    static func names(for vc: UIViewController) -> Names? {
        let raw = String(describing: type(of: vc))
        var short = raw

        // `UIHostingController<NavigationStack<…>>` → `UIHostingController`
        if let lt = short.firstIndex(of: "<") {
            short = String(short[..<lt])
        }

        // `MyApp.HomeViewController` → `HomeViewController`
        if let dot = short.lastIndex(of: ".") {
            short = String(short[short.index(after: dot)...])
        }

        if short.isEmpty || frameworkBaseClasses.contains(short) {
            return nil
        }
        return Names(display: short, full: raw)
    }
}
#endif
