#if DEBUG
import XCTest
@testable import ScreenNameViewer

/// 타입 이름 파서 단위 테스트 — Mirror 까지 가지 않고 문자열로 직접 검증
final class SwiftUIIntrospectionTests: XCTestCase {

    func testSimpleUserType() {
        let name = "MyApp.HomeView"
        XCTAssertEqual(SwiftUIIntrospection.firstUserType(inQualifiedTypeName: name), "HomeView")
    }

    func testGenericTypeUsesInnerUserType() {
        let name = "SwiftUI.AnyView<SwiftUI.ModifiedContent<MyApp.HomeView, SwiftUI.Foo>>"
        XCTAssertEqual(SwiftUIIntrospection.firstUserType(inQualifiedTypeName: name), "HomeView")
    }

    func testAllFrameworkReturnsNil() {
        let name = "SwiftUI.AnyView<SwiftUI.ModifiedContent<SwiftUI.Text, SwiftUI.Foo>>"
        XCTAssertNil(SwiftUIIntrospection.firstUserType(inQualifiedTypeName: name))
    }

    func testUnderscoreModuleSkipped() {
        // _SwiftUI 같은 underscore prefix 모듈은 사용자 코드로 잘못 판정 안 함
        let name = "_SwiftUI.PrivateType<MyApp.HomeView>"
        XCTAssertEqual(SwiftUIIntrospection.firstUserType(inQualifiedTypeName: name), "HomeView")
    }

    func testNestedFrameworkChainNotConfused() {
        // 회귀: 4단 nested 인 SwiftUI.NavigationState.StackContent.Key 에서
        // chain 전체를 한 덩어리로 스킵해야 함 (StackContent / Key 로 잘못 추출 X)
        let name = "Swift.Optional<SwiftUI.NavigationState.StackContent.Key>"
        XCTAssertNil(SwiftUIIntrospection.firstUserType(inQualifiedTypeName: name))
    }

    func testEmptyStringReturnsNil() {
        XCTAssertNil(SwiftUIIntrospection.firstUserType(inQualifiedTypeName: ""))
    }

    func testNoDotSingleIdentifierReturnsNil() {
        // ObjC 클래스 경로처럼 dot 없는 단순 이름
        XCTAssertNil(SwiftUIIntrospection.firstUserType(inQualifiedTypeName: "SomeType"))
    }

    func testSecondTokenIsUserTypeName() {
        // chain[0] = 사용자 모듈, chain[1] = top-level 사용자 타입
        let name = "MyApp.HomeViewController.NestedType"
        XCTAssertEqual(SwiftUIIntrospection.firstUserType(inQualifiedTypeName: name), "HomeViewController")
    }
}
#endif
