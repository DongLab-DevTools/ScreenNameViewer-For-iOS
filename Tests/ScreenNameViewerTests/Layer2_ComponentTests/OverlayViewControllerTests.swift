#if DEBUG
import XCTest
import UIKit
@testable import ScreenNameViewer

@MainActor
final class OverlayViewControllerTests: XCTestCase {

    private var vc: OverlayViewController!

    override func setUp() {
        super.setUp()
        vc = OverlayViewController()
        vc.loadViewIfNeeded()
    }

    override func tearDown() {
        vc = nil
        super.tearDown()
    }

    func testAllThreeLeftLabelsShowDistinctValues() {
        vc.update(
            vcDisplay: "ParentVC",
            childDisplay: "ChildVC",
            introspectedDisplay: "SwiftUIView",
            routeName: "Route",
            configuration: Configuration()
        )
        XCTAssertEqual(vc.vcLabel.text, "ParentVC")
        XCTAssertFalse(vc.vcLabel.isHidden)
        XCTAssertEqual(vc.childLabel.text, "ChildVC")
        XCTAssertFalse(vc.childLabel.isHidden)
        XCTAssertEqual(vc.introspectedLabel.text, "SwiftUIView")
        XCTAssertFalse(vc.introspectedLabel.isHidden)
        XCTAssertEqual(vc.routeLabel.text, "Route")
        XCTAssertFalse(vc.routeLabel.isHidden)
    }

    func testNilValuesHideLabels() {
        vc.update(
            vcDisplay: nil,
            childDisplay: nil,
            introspectedDisplay: nil,
            routeName: nil,
            configuration: Configuration()
        )
        XCTAssertTrue(vc.vcLabel.isHidden)
        XCTAssertTrue(vc.childLabel.isHidden)
        XCTAssertTrue(vc.introspectedLabel.isHidden)
        XCTAssertTrue(vc.routeLabel.isHidden)
    }

    func testChildDuplicateOfVCIsHidden() {
        vc.update(
            vcDisplay: "Same",
            childDisplay: "Same",
            introspectedDisplay: nil,
            routeName: nil,
            configuration: Configuration()
        )
        XCTAssertFalse(vc.vcLabel.isHidden)
        XCTAssertTrue(vc.childLabel.isHidden)
    }

    func testIntrospectedDuplicateOfChildIsHidden() {
        vc.update(
            vcDisplay: "Parent",
            childDisplay: "Inner",
            introspectedDisplay: "Inner",
            routeName: nil,
            configuration: Configuration()
        )
        XCTAssertFalse(vc.childLabel.isHidden)
        XCTAssertTrue(vc.introspectedLabel.isHidden)
    }

    func testEmptyStringTreatedAsHidden() {
        vc.update(
            vcDisplay: "",
            childDisplay: "",
            introspectedDisplay: "",
            routeName: "",
            configuration: Configuration()
        )
        XCTAssertTrue(vc.vcLabel.isHidden)
        XCTAssertTrue(vc.childLabel.isHidden)
        XCTAssertTrue(vc.introspectedLabel.isHidden)
        XCTAssertTrue(vc.routeLabel.isHidden)
    }

    // MARK: - Rotation policy

    func testOrientationFallbackToPortraitWhenNoHostWindow() {
        // OverlayVC 가 window 에 안 붙은 상태 — hostTopViewController() nil → portrait 로 보수적 fallback
        // 호스트 앱 회전 잠금을 우회하지 않도록 보장
        XCTAssertEqual(vc.supportedInterfaceOrientations, .portrait)
        XCTAssertFalse(vc.shouldAutorotate)
        XCTAssertEqual(vc.preferredInterfaceOrientationForPresentation, .portrait)
    }
}
#endif
