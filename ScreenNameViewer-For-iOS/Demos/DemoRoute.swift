import Foundation

enum DemoRoute: Hashable {

    // SwiftUI — 메뉴의 최상위 항목
    case swiftUIBasicNavigation
    case swiftUIDeepNavigation
    case swiftUISheet
    case swiftUIFullScreenCover
    case swiftUITabbed

    // SwiftUI — 중첩(같은 루트 NavigationStack에 push되는 하위 항목)
    case swiftUIBasicDetail(id: Int)
    case swiftUIDeepLevel(Int)

    // UIKit — 메뉴의 최상위 항목
    case uikitNavigationController
    case uikitTabBarController
    case uikitModalPresentation
    case uikitContainerViewController
}
