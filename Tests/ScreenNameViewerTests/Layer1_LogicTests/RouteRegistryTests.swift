#if DEBUG
import XCTest
@testable import ScreenNameViewer

final class RouteRegistryTests: XCTestCase {

    func testEmptyHasNoCurrent() {
        let registry = RouteRegistry()
        XCTAssertNil(registry.current)
    }

    func testSetMakesCurrent() {
        var registry = RouteRegistry()
        let id = UUID()
        registry.set(id: id, name: "Home")
        XCTAssertEqual(registry.current, "Home")
    }

    func testMostRecentSetIsCurrent() {
        var registry = RouteRegistry()
        registry.set(id: UUID(), name: "First")
        registry.set(id: UUID(), name: "Second")
        XCTAssertEqual(registry.current, "Second")
    }

    func testRemoveTopRestoresPrevious() {
        var registry = RouteRegistry()
        let first = UUID()
        let second = UUID()
        registry.set(id: first, name: "First")
        registry.set(id: second, name: "Second")
        registry.remove(id: second)
        XCTAssertEqual(registry.current, "First")
    }

    func testSetSameIdUpdatesInPlace() {
        var registry = RouteRegistry()
        let id = UUID()
        registry.set(id: id, name: "Old")
        registry.set(id: id, name: "New")
        XCTAssertEqual(registry.current, "New")
    }

    func testNilNameAllowed() {
        var registry = RouteRegistry()
        registry.set(id: UUID(), name: nil)
        XCTAssertNil(registry.current)
    }

    func testClearRemovesAll() {
        var registry = RouteRegistry()
        registry.set(id: UUID(), name: "A")
        registry.set(id: UUID(), name: "B")
        registry.clear()
        XCTAssertNil(registry.current)
    }
}
#endif
