#if DEBUG
import XCTest
import UIKit
import SwiftUI
@testable import ScreenNameViewer

final class FrameworkModulesTests: XCTestCase {

    func testAppleUIKitClassDetected() {
        // UIViewController 자체는 UIKit framework
        XCTAssertTrue(FrameworkModules.isAppleFrameworkClass(UIViewController.self))
        XCTAssertTrue(FrameworkModules.isAppleFrameworkClass(UINavigationController.self))
        XCTAssertTrue(FrameworkModules.isAppleFrameworkClass(UITabBarController.self))
    }

    func testAppleSwiftUIHostingClassDetected() {
        XCTAssertTrue(FrameworkModules.isAppleFrameworkClass(UIHostingController<MockHomeView>.self))
    }

    func testUserClassNotDetected() {
        // 테스트 모듈은 ScreenNameViewerTests — com.apple. prefix 아님
        XCTAssertFalse(FrameworkModules.isAppleFrameworkClass(MockUserViewController.self))
        XCTAssertFalse(FrameworkModules.isAppleFrameworkClass(MockUserNavigationController.self))
    }

    func testNamesSetContainsExpectedModules() {
        XCTAssertTrue(FrameworkModules.names.contains("SwiftUI"))
        XCTAssertTrue(FrameworkModules.names.contains("UIKit"))
        XCTAssertTrue(FrameworkModules.names.contains("Swift"))
        XCTAssertFalse(FrameworkModules.names.contains("MyApp"))
    }
}
#endif
