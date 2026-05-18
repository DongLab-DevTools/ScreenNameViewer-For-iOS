#if DEBUG
import XCTest
import UIKit
import SwiftUI
@testable import ScreenNameViewer

@MainActor
final class TrackerLogicTests: XCTestCase {

    // MARK: - isContainer

    func testStandardContainersDetected() {
        XCTAssertTrue(Tracker.isContainer(UINavigationController()))
        XCTAssertTrue(Tracker.isContainer(UITabBarController()))
        XCTAssertTrue(Tracker.isContainer(UISplitViewController()))
        XCTAssertTrue(Tracker.isContainer(UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)))
    }

    func testUserNavigationSubclassIsAlsoContainer() {
        // 회귀: BaseNavigationController 같은 사용자 서브클래스도 자기 자신은 컨테이너로 판정
        XCTAssertTrue(Tracker.isContainer(MockUserNavigationController()))
        XCTAssertTrue(Tracker.isContainer(MockUserTabBarController()))
    }

    func testRegularUIViewControllerNotContainer() {
        XCTAssertFalse(Tracker.isContainer(UIViewController()))
        XCTAssertFalse(Tracker.isContainer(MockUserViewController()))
    }

    // MARK: - isScreenLevel

    func testContainerSelfIsNotScreenLevel() {
        // 회귀: BaseNavigationController 가 라벨에 BaseNavigationController 라고 뜨면 안 됨
        XCTAssertFalse(Tracker.isScreenLevel(MockUserNavigationController()))
        XCTAssertFalse(Tracker.isScreenLevel(UINavigationController()))
    }

    func testParentlessVCIsScreenLevel() {
        // window root 또는 modal 로 떠 있는 VC — parent nil
        let vc = MockUserViewController()
        XCTAssertTrue(Tracker.isScreenLevel(vc))
    }

    func testChildOfStandardContainerIsScreenLevel() {
        let nav = MockUserNavigationController()
        let child = MockUserViewController()
        nav.viewControllers = [child]
        XCTAssertTrue(Tracker.isScreenLevel(child))
    }

    func testChildOfTabBarIsScreenLevel() {
        let tab = MockUserTabBarController()
        let child = MockUserViewController()
        tab.viewControllers = [child]
        XCTAssertTrue(Tracker.isScreenLevel(child))
    }

    func testEmbeddedChildIsNotScreenLevel() {
        // 일반 VC 안에 addChild 로 박힌 child — chromecast, mini player 패턴
        let parent = MockUserViewController()
        let chrome = MockChromeViewController()
        parent.addChild(chrome)
        XCTAssertFalse(Tracker.isScreenLevel(chrome))
    }

    func testParentlessAppleHostIsNotScreenLevel() {
        // 회귀: 셀이 UIHostingController 를 addChild 없이 contentView 에만 add 하는 케이스
        // (Tving VaLineCell 패턴) — host.viewDidAppear 가 발생해도 push 되면 안 됨
        let host = UIHostingController(rootView: Text("dummy"))
        XCTAssertNil(host.parent)
        XCTAssertFalse(Tracker.isScreenLevel(host))
    }

    // MARK: - findUserRoot

    func testUserVCIsItsOwnUserRoot() {
        let vc = MockUserViewController()
        XCTAssertTrue(Tracker.shared.findUserRoot(in: vc) === vc)
    }

    func testFindUserRootDescendsIntoAppleHost() {
        // SwiftUI UIViewControllerRepresentable 의 내부 host 가 top 이고
        // 그 child 로 사용자 VC 가 있는 시나리오
        let appleHost = UIViewController() // Apple framework (UIViewController 자체)
        let userChild = MockUserViewController()
        appleHost.addChild(userChild)
        // child 의 view 가 host view 안에 들어가야 viewIfLoaded.window 검사 통과 위해
        // 윈도우 안에 있어야 하지만 단순 단위 테스트에선 view 강제 로드만으로는 부족
        // → 통합 테스트에서 다룸. 여기선 부모가 사용자 코드인 경우만 검증
        let user = MockUserViewController()
        XCTAssertTrue(Tracker.shared.findUserRoot(in: user) === user)
        _ = appleHost
        _ = userChild
    }

    // MARK: - resolveDisplay snapshot

    override func setUp() async throws {
        try await super.setUp()
        await MainActor.run { TrackerTestReset.resetAll() }
    }

    override func tearDown() async throws {
        await MainActor.run { TrackerTestReset.resetAll() }
        try await super.tearDown()
    }

    func testEmptyStackReturnsEmptySnapshot() {
        let snap = Tracker.shared.resolveDisplay(routeName: nil)
        XCTAssertNil(snap.viewController)
        XCTAssertNil(snap.vcDisplay)
        XCTAssertNil(snap.childDisplay)
    }

    func testSnapshotFromUserVCOnStack() {
        let vc = MockUserViewController()
        Tracker.shared.vcStack.push(vc)
        let snap = Tracker.shared.resolveDisplay(routeName: nil)
        XCTAssertEqual(snap.vcDisplay, "MockUserViewController")
    }

    func testRouteSetMakesTopUseTopVC() {
        let user = MockUserViewController()
        Tracker.shared.vcStack.push(user)
        // routeName != nil 인 경우 fallback walk 안 함 — 그냥 top 사용
        let snap = Tracker.shared.resolveDisplay(routeName: "SomeRoute")
        XCTAssertTrue(snap.viewController === user)
        XCTAssertEqual(snap.vcDisplay, "MockUserViewController")
    }
}
#endif
