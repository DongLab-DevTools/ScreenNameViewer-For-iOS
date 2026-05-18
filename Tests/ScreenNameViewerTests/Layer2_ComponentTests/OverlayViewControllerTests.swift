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

    func testOrientationFallbackIsPermissiveWhenNoHostWindow() {
        // OverlayVC 가 window 에 안 붙은 transient 상태 — hostTopViewController() nil
        // fallback 은 permissive 여야 함: OverlayWindow 가 호스트의 landscape 허용을
        // 막아버리지 않도록. 최종 회전 정책 결정자는 호스트 앱
        XCTAssertEqual(vc.supportedInterfaceOrientations, .all)
        XCTAssertTrue(vc.shouldAutorotate)
        XCTAssertEqual(vc.preferredInterfaceOrientationForPresentation, .portrait)
    }
}
#endif
