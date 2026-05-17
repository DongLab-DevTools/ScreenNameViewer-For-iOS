#if DEBUG
import XCTest
import UIKit
import SwiftUI
@testable import ScreenNameViewer

@MainActor
final class VCNameFormatterTests: XCTestCase {

    func testUserVCReturnsShortName() {
        let name = VCNameFormatter.displayName(for: MockUserViewController())
        XCTAssertEqual(name, "MockUserViewController")
    }

    func testUserNavigationSubclassReturnsName() {
        let name = VCNameFormatter.displayName(for: MockUserNavigationController())
        XCTAssertEqual(name, "MockUserNavigationController")
    }

    func testAppleUIKitClassReturnsNil() {
        XCTAssertNil(VCNameFormatter.displayName(for: UIViewController()))
        XCTAssertNil(VCNameFormatter.displayName(for: UINavigationController()))
        XCTAssertNil(VCNameFormatter.displayName(for: UITabBarController()))
        XCTAssertNil(VCNameFormatter.displayName(for: UIAlertController()))
    }

    func testSwiftUIHostingControllerReturnsNil() {
        let host = UIHostingController(rootView: MockHomeView())
        XCTAssertNil(VCNameFormatter.displayName(for: host))
    }

    func testUserHostingSubclassReturnsName() {
        class MyHostingController: UIHostingController<MockHomeView> {}
        let host = MyHostingController(rootView: MockHomeView())
        XCTAssertEqual(VCNameFormatter.displayName(for: host), "MyHostingController")
    }
}
#endif
