#if DEBUG
import XCTest
import UIKit
import SwiftUI
@testable import ScreenNameViewer

/// SwiftUI .trackScreenName modifier 가 onAppear/onDisappear 로 RouteRegistry 갱신하는지 검증
@MainActor
final class TrackScreenNameIntegrationTests: XCTestCase {

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

    func testStringRouteRegistersOnAppear() {
        let host = UIHostingController(rootView: Text("hi").trackScreenName("TestRoute"))
        testWindow = TestWindow(rootViewController: host)
        // onAppear 는 다음 run loop 사이클에 fire
        let exp = XCTestExpectation(description: "onAppear")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(Tracker.shared.routes.current, "TestRoute")
    }

    func testPathBasedRouteUsesLastElement() {
        let path: [String] = ["First", "Second", "Third"]
        let host = UIHostingController(
            rootView: NavigationStack { Text("hi") }.trackScreenName(path: path)
        )
        testWindow = TestWindow(rootViewController: host)
        let exp = XCTestExpectation(description: "onAppear")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(Tracker.shared.routes.current, "Third")
    }

    func testEmptyPathHasNilRoute() {
        let path: [String] = []
        let host = UIHostingController(
            rootView: NavigationStack { Text("hi") }.trackScreenName(path: path)
        )
        testWindow = TestWindow(rootViewController: host)
        let exp = XCTestExpectation(description: "onAppear")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertNil(Tracker.shared.routes.current)
    }
}
#endif
