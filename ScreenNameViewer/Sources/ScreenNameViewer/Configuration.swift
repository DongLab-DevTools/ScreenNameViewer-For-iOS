import UIKit

/// 오버레이의 시각적 설정
///
/// 두 라벨 스타일은 Android 라이브러리의 `activityName` / `composeRouteName`
/// 설정 블록과 1:1 대응 — `viewController`는 화면 **좌측**에 현재
/// `UIViewController`(Android Activity 대응), `route`는 화면 **우측**에
/// 현재 SwiftUI `NavigationStack` 라우트(Android Compose Route 대응)
///
/// 수직 방향(top/bottom)만 설정 가능 — 수평 위치는 Android UX와 동일하게
/// 좌/우 고정
public struct Configuration {

    public var viewController: LabelStyle
    public var route: LabelStyle
    public var verticalPosition: VerticalPosition

    public init(
        viewController: LabelStyle = .defaultViewController,
        route: LabelStyle = .defaultRoute,
        verticalPosition: VerticalPosition = .top
    ) {
        self.viewController = viewController
        self.route = route
        self.verticalPosition = verticalPosition
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
