import UIKit

/// Visual configuration for the overlay.
///
/// The two label styles mirror Android's `activityName` / `composeRouteName`
/// configuration blocks: `viewController` is rendered for the current
/// `UIViewController`, `route` is rendered for the current SwiftUI
/// `NavigationStack` route.
public struct Configuration {

    public var viewController: LabelStyle
    public var route: LabelStyle
    public var verticalPosition: VerticalPosition
    public var horizontalPosition: HorizontalPosition

    public init(
        viewController: LabelStyle = .defaultViewController,
        route: LabelStyle = .defaultRoute,
        verticalPosition: VerticalPosition = .top,
        horizontalPosition: HorizontalPosition = .leading
    ) {
        self.viewController = viewController
        self.route = route
        self.verticalPosition = verticalPosition
        self.horizontalPosition = horizontalPosition
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

    public enum HorizontalPosition {
        case leading
        case center
        case trailing
    }
}
