#if DEBUG
import XCTest
import UIKit
@testable import ScreenNameViewer

@MainActor
final class OverlayViewTests: XCTestCase {

    private var view: OverlayView!

    override func setUp() {
        super.setUp()
        view = OverlayView()
        view.layoutIfNeeded()
    }

    override func tearDown() {
        view = nil
        super.tearDown()
    }

    func testAllThreeLeftLabelsShowDistinctValues() {
        view.update(
            vcDisplay: "ParentVC",
            childDisplay: "ChildVC",
            introspectedDisplay: "SwiftUIView",
            routeName: "Route",
            configuration: Configuration()
        )
        XCTAssertEqual(view.vcLabel.text, "ParentVC")
        XCTAssertFalse(view.vcLabel.isHidden)
        XCTAssertEqual(view.childLabel.text, "ChildVC")
        XCTAssertFalse(view.childLabel.isHidden)
        XCTAssertEqual(view.introspectedLabel.text, "SwiftUIView")
        XCTAssertFalse(view.introspectedLabel.isHidden)
        XCTAssertEqual(view.routeLabel.text, "Route")
        XCTAssertFalse(view.routeLabel.isHidden)
    }

    func testNilValuesHideLabels() {
        view.update(
            vcDisplay: nil,
            childDisplay: nil,
            introspectedDisplay: nil,
            routeName: nil,
            configuration: Configuration()
        )
        XCTAssertTrue(view.vcLabel.isHidden)
        XCTAssertTrue(view.childLabel.isHidden)
        XCTAssertTrue(view.introspectedLabel.isHidden)
        XCTAssertTrue(view.routeLabel.isHidden)
    }

    func testChildDuplicateOfVCIsHidden() {
        view.update(
            vcDisplay: "Same",
            childDisplay: "Same",
            introspectedDisplay: nil,
            routeName: nil,
            configuration: Configuration()
        )
        XCTAssertFalse(view.vcLabel.isHidden)
        XCTAssertTrue(view.childLabel.isHidden)
    }

    func testIntrospectedDuplicateOfChildIsHidden() {
        view.update(
            vcDisplay: "Parent",
            childDisplay: "Inner",
            introspectedDisplay: "Inner",
            routeName: nil,
            configuration: Configuration()
        )
        XCTAssertFalse(view.childLabel.isHidden)
        XCTAssertTrue(view.introspectedLabel.isHidden)
    }

    func testEmptyStringTreatedAsHidden() {
        view.update(
            vcDisplay: "",
            childDisplay: "",
            introspectedDisplay: "",
            routeName: "",
            configuration: Configuration()
        )
        XCTAssertTrue(view.vcLabel.isHidden)
        XCTAssertTrue(view.childLabel.isHidden)
        XCTAssertTrue(view.introspectedLabel.isHidden)
        XCTAssertTrue(view.routeLabel.isHidden)
    }

    func testTouchPassthrough() {
        // 라이브러리 라벨 view 는 호스트 앱 터치를 가로채지 않아야 함 — point(inside:) 항상 false
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        XCTAssertFalse(view.point(inside: CGPoint(x: 10, y: 10), with: nil))
        XCTAssertFalse(view.point(inside: CGPoint(x: 160, y: 280), with: nil))
    }
}
#endif
