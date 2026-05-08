#if DEBUG
import UIKit

/// `UIViewController` 인스턴스를 오버레이 표시용 이름으로 변환
///
/// 계약 — 오버레이의 모든 표시 이름은 개발자 코드베이스에서 grep 가능한
/// 심볼. 어떤 사용자 파일로도 연결 불가능한 프레임워크 베이스 클래스(예:
/// `UIHostingController<...>`)면 nil 반환 → vc 라벨 자동 미표시. 이 경우
/// SwiftUI `.trackScreenName(...)` 모디파이어가 의미 있는 라우트 이름 제공 전제
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

    static func displayName(for vc: UIViewController) -> String? {
        var name = String(describing: type(of: vc))

        // `UIHostingController<NavigationStack<…>>` → `UIHostingController`
        if let lt = name.firstIndex(of: "<") {
            name = String(name[..<lt])
        }

        // `MyApp.HomeViewController` → `HomeViewController`
        if let dot = name.lastIndex(of: ".") {
            name = String(name[name.index(after: dot)...])
        }

        if name.isEmpty || frameworkBaseClasses.contains(name) {
            return nil
        }
        return name
    }
}
#endif
