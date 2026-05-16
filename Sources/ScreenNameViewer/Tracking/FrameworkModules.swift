#if DEBUG
import Foundation

/// "사용자 코드 아닌 Apple framework / Swift runtime" 판정
///
/// 두 가지 신호를 같이 노출 — 검사 대상이 Swift type 인지 ObjC class 인지에 따라 다름
/// - Swift type (struct / generic class): `String(reflecting:)` 가 항상 `Module.Type` 형태
///   → 첫 토큰(모듈명) 이 `names` 에 속하는지로 판정
/// - ObjC class: `String(reflecting:)` 가 모듈 prefix 없이 클래스명만 줄 수 있음
///   → `Bundle(for:).bundleIdentifier` 가 `com.apple.` 로 시작하는지로 판정
///
/// SwiftUI View 구조체 트리 탐색은 (1) 방식, UIViewController 클래스 식별은 (2) 방식 사용
enum FrameworkModules {

    /// `String(reflecting:)` 결과의 모듈 토큰이 framework 인지
    /// Apple 이 새 SwiftUI 내부 타입을 추가해도 이 list 는 그대로 — 프레임워크 모듈명을 바꾸지 않는 한
    static let names: Set<String> = [
        "Swift",
        "SwiftUI",
        "UIKit",
        "UIKitCore",
        "Foundation",
        "Combine",
        "CoreFoundation",
        "CoreGraphics",
        "QuartzCore",
        "ObjectiveC",
        "Darwin",
        "Dispatch",
        "os",
    ]

    /// ObjC 클래스가 Apple 소유 프레임워크에 속하는지
    /// 사용자 앱 / 서드파티 SPM 은 `com.apple.` prefix 가 아니므로 false
    static func isAppleFrameworkClass(_ cls: AnyClass) -> Bool {
        let id = Bundle(for: cls).bundleIdentifier ?? ""
        return id.hasPrefix("com.apple.")
    }
}
#endif
