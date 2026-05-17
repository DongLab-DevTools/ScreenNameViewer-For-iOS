#if DEBUG
import XCTest
import UIKit
@testable import ScreenNameViewer

@MainActor
final class TrackerHandleTests: XCTestCase {

    override func setUp() {
        super.setUp()
        TrackerTestReset.resetAll()
        Tracker.shared.start(configuration: Configuration())
    }

    override func tearDown() {
        TrackerTestReset.resetAll()
        super.tearDown()
    }

    func testHandleAppearPushesScreenLevelVC() {
        let vc = MockUserViewController()
        Tracker.shared.handleViewDidAppear(vc)
        XCTAssertTrue(Tracker.shared.vcStack.top === vc)
    }

    func testHandleAppearSkipsContainerSelf() {
        let nav = MockUserNavigationController()
        Tracker.shared.handleViewDidAppear(nav)
        XCTAssertNil(Tracker.shared.vcStack.top)
    }

    func testHandleAppearSkipsEmbeddedChild() {
        let parent = MockUserViewController()
        let chrome = MockChromeViewController()
        parent.addChild(chrome)
        chrome.didMove(toParent: parent)
        Tracker.shared.handleViewDidAppear(chrome)
        XCTAssertFalse((Tracker.shared.vcStack.top === chrome))
    }

    func testHandleAppearPushesChildOfStandardContainer() {
        let nav = MockUserNavigationController()
        let child = MockUserViewController()
        nav.viewControllers = [child]
        Tracker.shared.handleViewDidAppear(child)
        XCTAssertTrue(Tracker.shared.vcStack.top === child)
    }

    func testHandleDisappearRemovesFromStack() {
        let vc = MockUserViewController()
        Tracker.shared.handleViewDidAppear(vc)
        Tracker.shared.handleViewDidDisappear(vc)
        XCTAssertNil(Tracker.shared.vcStack.top)
    }

    func testHandleAppearWhenNotRunningIsNoOp() {
        Tracker.shared.stop()
        let vc = MockUserViewController()
        Tracker.shared.handleViewDidAppear(vc)
        XCTAssertNil(Tracker.shared.vcStack.top)
    }

    func testSetRouteRegistersInRegistry() {
        let id = UUID()
        Tracker.shared.setRoute(id: id, name: "TestRoute")
        XCTAssertEqual(Tracker.shared.routes.current, "TestRoute")
    }

    func testRemoveRouteClearsCurrent() {
        let id = UUID()
        Tracker.shared.setRoute(id: id, name: "TestRoute")
        Tracker.shared.removeRoute(id: id)
        XCTAssertNil(Tracker.shared.routes.current)
    }
}
#endif
