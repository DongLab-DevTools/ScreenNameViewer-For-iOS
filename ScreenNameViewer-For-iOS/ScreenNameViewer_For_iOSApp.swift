//
//  ScreenNameViewer_For_iOSApp.swift
//  ScreenNameViewer-For-iOS
//

import SwiftUI
import ScreenNameViewer

@main
struct ScreenNameViewer_For_iOSApp: App {

    init() {
        // 한 줄 초기화 — RELEASE에서는 빈 함수로 컴파일되어 swizzling /
        // 오버레이 윈도우 / 런타임 비용 모두 0
        ScreenNameViewer.start { config in
            // 선택 — 여기서 외형 커스터마이즈
            // config.viewController.textColor = .systemGreen
            // config.verticalPosition = .bottom

            // mini-player chrome 류 (항상 떠있는 child VC) 는 추적에서 제외
            // → 본래 화면의 라벨이 그대로 유지됨
            config.excludedClassNames = ["MiniPlayerChromeViewController"]
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
