import UIKit

/// 오버레이 시각 설정
///
/// 두 라벨 스타일은 Android 라이브러리의 `activityName` / `composeRouteName` 블록과 1:1 대응
/// `viewController`: 좌측, 현재 `UIViewController` (= Android Activity)
/// `route`: 우측, 현재 SwiftUI `NavigationStack` 라우트 (= Android Compose Route)
///
/// 수직 방향(top/bottom)만 설정 가능, 수평은 Android와 동일하게 좌/우 고정
public struct Configuration {

    public var viewController: LabelStyle
    public var route: LabelStyle
    public var verticalPosition: VerticalPosition

    /// 추적 대상에서 제외할 `UIViewController` 클래스명 집합
    /// 예: 화면 위에 항상 떠있는 mini-player chrome 같은 child container를 제외해
    ///     이전 화면의 라벨이 그대로 노출되도록 만들 때 사용
    /// 매칭: `String(describing: type(of: vc))`의 모듈 prefix를 제거한 짧은 이름과 비교
    public var excludedClassNames: Set<String>

    public init(
        viewController: LabelStyle = .defaultViewController,
        route: LabelStyle = .defaultRoute,
        verticalPosition: VerticalPosition = .top,
        excludedClassNames: Set<String> = []
    ) {
        self.viewController = viewController
        self.route = route
        self.verticalPosition = verticalPosition
        self.excludedClassNames = excludedClassNames
    }

    public struct LabelStyle {
        public var textColor: UIColor
        public var backgroundColor: UIColor
        public var textSize: CGFloat
        public var enabled: Bool
        public var paddingHorizontal: CGFloat
        public var paddingVertical: CGFloat
        public var cornerRadius: CGFloat

        public init(
            textColor: UIColor,
            backgroundColor: UIColor,
            textSize: CGFloat = 12,
            enabled: Bool = true,
            paddingHorizontal: CGFloat = 6,
            paddingVertical: CGFloat = 2,
            cornerRadius: CGFloat = 4
        ) {
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.textSize = textSize
            self.enabled = enabled
            self.paddingHorizontal = paddingHorizontal
            self.paddingVertical = paddingVertical
            self.cornerRadius = cornerRadius
        }

        public static let defaultViewController = LabelStyle(
            textColor: .white,
            backgroundColor: UIColor.black.withAlphaComponent(0.7)
        )

        public static let defaultRoute = LabelStyle(
            textColor: .systemYellow,
            backgroundColor: UIColor.black.withAlphaComponent(0.7)
        )
    }

    public enum VerticalPosition {
        case top
        case bottom
    }
}
