import Foundation

enum DemoRoute: Hashable {

    // SwiftUI – top-level entries from the menu
    case swiftUIBasicNavigation
    case swiftUIDeepNavigation
    case swiftUISheet
    case swiftUIFullScreenCover
    case swiftUITabbed

    // SwiftUI – nested (pushed onto the same root NavigationStack)
    case swiftUIBasicDetail(id: Int)
    case swiftUIDeepLevel(Int)

    // UIKit – top-level entries from the menu
    case uikitNavigationController
    case uikitTabBarController
    case uikitModalPresentation
    case uikitContainerViewController
}
