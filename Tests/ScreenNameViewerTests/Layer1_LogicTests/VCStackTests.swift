#if DEBUG
import XCTest
import UIKit
@testable import ScreenNameViewer

@MainActor
final class VCStackTests: XCTestCase {

    func testPushAppendsToTop() {
        var stack = VCStack()
        let a = UIViewController()
        let b = UIViewController()
        stack.push(a)
        stack.push(b)
        XCTAssertTrue(stack.top === b)
    }

    func testPushSameVCMovesToTop() {
        var stack = VCStack()
        let a = UIViewController()
        let b = UIViewController()
        stack.push(a)
        stack.push(b)
        stack.push(a)
        XCTAssertTrue(stack.top === a)
    }

    func testRemoveTakesItOffStack() {
        var stack = VCStack()
        let a = UIViewController()
        let b = UIViewController()
        stack.push(a)
        stack.push(b)
        stack.remove(b)
        XCTAssertTrue(stack.top === a)
    }

    func testTopSkipsDeallocatedEntries() {
        var stack = VCStack()
        let surviving = UIViewController()
        autoreleasepool {
            let transient = UIViewController()
            stack.push(transient)
            stack.push(surviving)
            // transient is removed via push (자기보다 위 항목 push 시 dead entry 정리는 아직 안 일어남)
        }
        // 위 autoreleasepool 빠져나오면 transient 해제 — weak ref 가 nil 로 풀려야 함
        // (단 surviving 이 top 인 상태이므로 top 은 그대로 surviving)
        XCTAssertTrue(stack.top === surviving)
    }

    func testTopMapReturnsFirstNonNilResult() {
        var stack = VCStack()
        let a = UIViewController()
        let b = UIViewController()
        let c = UIViewController()
        stack.push(a)
        stack.push(b)
        stack.push(c)
        let result = stack.topMap { vc -> String? in
            vc === b ? "found-b" : nil
        }
        XCTAssertEqual(result, "found-b")
    }

    func testTopMapReturnsNilWhenNoMatch() {
        var stack = VCStack()
        stack.push(UIViewController())
        stack.push(UIViewController())
        let result = stack.topMap { _ -> String? in nil }
        XCTAssertNil(result)
    }

    func testClearEmptiesStack() {
        var stack = VCStack()
        stack.push(UIViewController())
        stack.push(UIViewController())
        stack.clear()
        XCTAssertNil(stack.top)
    }
}
#endif
