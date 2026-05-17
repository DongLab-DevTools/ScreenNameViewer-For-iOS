#if DEBUG
import XCTest
import UIKit
@testable import ScreenNameViewer

/// 실 윈도우에 VC 를 올려 viewDidAppear 가 swizzling 으로 가로채져 스택에 반영되는지 검증
@MainActor
final class SwizzleIntegrationTests: XCTestCase {

    private var testWindow: TestWindow?

    override func setUp() {
        super.setUp()
        TrackerTestReset.resetAll()
        Tracker.shared.start(configuration: Configuration())
    }

    override func tearDown() {
        testWindow?.tearDown()
        testWindow = nil
        TrackerTestReset.resetAll()
        super.tearDown()
    }

    func testSimpleVCAppearTracked() {
        let vc = MockUserViewController()
        testWindow = TestWindow(rootViewController: vc)
        runLoopOnce()
        XCTAssertTrue(Tracker.shared.vcStack.top === vc)
    }

    func testNavigationStackPushTracked() {
        let nav = MockUserNavigationController(rootViewController: MockUserViewController())
        testWindow = TestWindow(rootViewController: nav)
        runLoopOnce()

        let pushed = MockUserSecondViewController()
        nav.pushViewController(pushed, animated: false)
        runLoopOnce()

        XCTAssertTrue(Tracker.shared.vcStack.top === pushed)
    }

    func testEmbeddedChildDoesNotReplaceTop() {
        // 회귀: chromecast / mini player 류 child VC 가 부모 라벨 덮지 않음
        let parent = MockUserViewController()
        testWindow = TestWindow(rootViewController: parent)
        runLoopOnce()
        XCTAssertTrue(Tracker.shared.vcStack.top === parent)

        let chrome = MockChromeViewController()
        parent.addChild(chrome)
        parent.view.addSubview(chrome.view)
        chrome.didMove(toParent: parent)
        runLoopOnce()

        XCTAssertTrue(Tracker.shared.vcStack.top === parent)
    }
}
#endif
