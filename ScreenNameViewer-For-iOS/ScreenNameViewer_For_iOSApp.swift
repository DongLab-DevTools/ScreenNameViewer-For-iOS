//
//  ScreenNameViewer_For_iOSApp.swift
//  ScreenNameViewer-For-iOS
//

import SwiftUI
import ScreenNameViewer

@main
struct ScreenNameViewer_For_iOSApp: App {

    init() {
        // One-line initialization. In RELEASE this call compiles to an empty
        // function; no swizzling, no overlay window, no runtime cost.
        ScreenNameViewer.start { config in
            // Optional: customize appearance here.
            // config.viewController.textColor = .systemGreen
            // config.verticalPosition = .bottom
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
