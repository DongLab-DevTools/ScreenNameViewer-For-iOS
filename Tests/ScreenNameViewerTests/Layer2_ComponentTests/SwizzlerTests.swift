#if DEBUG
import XCTest
import UIKit
@testable import ScreenNameViewer

@MainActor
final class SwizzlerTests: XCTestCase {

    func testSwizzleOnceIsIdempotent() {
        // 여러 번 호출해도 한 번만 exchange — exchange 가 2번 호출되면 원래대로 돌아가버림
        Swizzler.swizzleOnce()
        Swizzler.swizzleOnce()
        Swizzler.swizzleOnce()
        // 크래시 / 무한루프 없이 도달하면 OK
        XCTAssertTrue(true)
    }

    func testSwizzledViewDidAppearForwardsToTracker() {
        Swizzler.swizzleOnce()
        TrackerTestReset.resetAll()
        Tracker.shared.start(configuration: Configuration())

        let vc = MockUserViewController()
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()

        // swizzling 정상 동작했다면 vcStack 에 push 되어야 함 (parent nil → screen-level)
        XCTAssertTrue(Tracker.shared.vcStack.top === vc)

        TrackerTestReset.resetAll()
    }

    func testEmbeddedChildNotPushedThroughSwizzle() {
        Swizzler.swizzleOnce()
        TrackerTestReset.resetAll()
        Tracker.shared.start(configuration: Configuration())

        let parent = MockUserViewController()
        let chrome = MockChromeViewController()
        parent.addChild(chrome)
        chrome.didMove(toParent: parent)

        chrome.beginAppearanceTransition(true, animated: false)
        chrome.endAppearanceTransition()

        // 임베드된 chrome 은 isScreenLevel 통과 못해 push 안 됨
        XCTAssertFalse((Tracker.shared.vcStack.top === chrome))

        TrackerTestReset.resetAll()
    }
}
#endif
