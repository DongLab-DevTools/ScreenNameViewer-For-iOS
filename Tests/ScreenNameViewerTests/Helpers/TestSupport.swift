#if DEBUG
import XCTest
import UIKit
import SwiftUI
@testable import ScreenNameViewer

/// Tracker.shared 가 싱글톤이라 테스트 간 상태 격리 위해 매 테스트 전후로 호출
@MainActor
enum TrackerTestReset {
    static func resetAll() {
        Tracker.shared.stop()
        Tracker.shared.vcStack.clear()
        Tracker.shared.routes.clear()
    }
}

/// 메인 큐에 dispatch 된 async 작업이 완료될 때까지 대기
@MainActor
func runLoopOnce() {
    let exp = XCTestExpectation(description: "runloop")
    DispatchQueue.main.async { exp.fulfill() }
    let waiter = XCTWaiter()
    _ = waiter.wait(for: [exp], timeout: 1.0)
}

/// UIWindow 가 필요한 통합 테스트용 — 임시 윈도우 + 자동 정리
@MainActor
final class TestWindow {
    let window: UIWindow

    init(rootViewController: UIViewController) {
        let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        if let scene {
            window = UIWindow(windowScene: scene)
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    deinit {
        // teardown 은 호출 측에서 명시적으로 수행 (deinit 은 nonisolated)
    }

    func tearDown() {
        window.isHidden = true
        window.rootViewController = nil
    }
}
#endif
