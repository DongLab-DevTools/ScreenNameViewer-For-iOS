#if DEBUG
import UIKit

/// `UIViewController`를 오버레이 표시용 이름으로 변환
///
/// 계약: 표시되는 이름은 모두 사용자 코드베이스에서 grep 가능한 심볼
/// 프레임워크 베이스 클래스(예: `UIHostingController<...>`)는 nil 반환 → vc 라벨 자동 미표시
/// SwiftUI 화면은 `.trackScreenName(...)`이 라우트 이름 제공 전제
enum VCNameFormatter {

    private static let frameworkBaseClasses: Set<String> = [
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
    ]

    /// `display`: 라벨용 짧은 이름
    /// `full`: 토스트용 풀네임 (모듈 프리픽스 + 제너릭 포함)
    struct Names {
        let display: String
        let full: String
    }

    static func names(for vc: UIViewController) -> Names? {
        let raw = String(describing: type(of: vc))
        let short = shortName(fromRaw: raw)

        if short.isEmpty || frameworkBaseClasses.contains(short) {
            return nil
        }
        return Names(display: short, full: raw)
    }

    /// 모듈 prefix와 제너릭 인자를 제거한 짧은 클래스명만 반환
    /// `Configuration.excludedClassNames` 매칭처럼 프레임워크 베이스 필터링 전 단계에서 쓰임
    static func shortName(for vc: UIViewController) -> String {
        shortName(fromRaw: String(describing: type(of: vc)))
    }

    private static func shortName(fromRaw raw: String) -> String {
        var short = raw
        // `UIHostingController<NavigationStack<…>>` → `UIHostingController`
        if let lt = short.firstIndex(of: "<") {
            short = String(short[..<lt])
        }
        // `MyApp.HomeViewController` → `HomeViewController`
        if let dot = short.lastIndex(of: ".") {
            short = String(short[short.index(after: dot)...])
        }
        return short
    }
}
#endif
