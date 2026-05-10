# ScreenNameViewer-For-iOS
[![Hits](https://myhits.vercel.app/api/hit/https%3A%2F%2Fgithub.com%2FDongLab-DevTools%2FScreenNameViewer-For-iOS%3Ftab%3Dreadme-ov-file?color=blue&label=hits&size=small)](https://myhits.vercel.app)
[![Platform](https://img.shields.io/badge/platform-iOS-000000?style=flat-square&logo=apple)](https://developer.apple.com/ios)
[![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue?style=flat-square)](https://developer.apple.com/ios)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat-square&logo=swift)](https://swift.org)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen?style=flat-square)](https://swift.org/package-manager/)
![GitHub stars](https://img.shields.io/github/stars/DongLab-DevTools/ScreenNameViewer-For-iOS.svg)



**[한국어 README](./README_ko.md)**

## Overview

<!-- Sample image placeholder -->
<!-- ![sample](.github/docs/images/screennameviewer-example.png) -->

ScreenNameViewer is a debugging tool that overlays the class name of the currently displayed screen.
It allows you to intuitively check which screen is active, and in a SwiftUI environment, it can also display the `NavigationStack` route.

This allows you to quickly find and navigate to the code for the desired screen, improving both debugging and development efficiency.

<br>

## Features

- **Real-time class name display**: Shows `UIViewController` class names and `NavigationStack` route on screen in real-time
- **Automatic lifecycle tracking**: Automatically tracks all `UIViewController`s using method swizzling at the application level
- **Debug-only**: All internal code wrapped in `#if DEBUG` — automatically disabled in RELEASE builds with zero runtime cost
- **UI customization**: Freely configure text size, color, vertical position, etc.
- **Memory safe**: Prevents memory leaks using weak references and automatic cleanup
- **Touch interaction**: Tap label to display full class name in toast — non-label areas pass through, never blocking the underlying app
- **Both SwiftUI and UIKit**: One library covers both frameworks

<br>

## Installation

### Swift Package Manager

In Xcode, `File → Add Package Dependencies...` and enter:

```
https://github.com/DongLab-DevTools/ScreenNameViewer-For-iOS
```

Or add directly to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/DongLab-DevTools/ScreenNameViewer-For-iOS", from: "1.0.0")
]
```

Add to your target's dependencies:

```swift
.target(
    name: "MyApp",
    dependencies: ["ScreenNameViewer"]
)
```

<br>

### Requirements

- iOS 16.0 or higher
- Swift 5.9 or higher (Xcode 15+)

<br>

## Usage

### UIKit

Call `ScreenNameViewer.start()` once in your `AppDelegate`. Every `UIViewController` is then automatically tracked via method swizzling — no further code changes needed.

```swift
import UIKit
import ScreenNameViewer

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ScreenNameViewer.start()
        return true
    }
}
```

The left label automatically displays the class name of the currently visible `UIViewController`.

<br>

### SwiftUI

#### 1. Initialize at the App entry point

```swift
import SwiftUI
import ScreenNameViewer

@main
struct MyApp: App {
    init() {
        ScreenNameViewer.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

This alone tracks every screen, but SwiftUI views are hosted by `UIHostingController` whose class name is filtered out as framework noise. To show meaningful names for SwiftUI screens, add the modifiers below.

#### 2. Track NavigationStack routes

Apply once on the root `NavigationStack`. Push/pop transitions automatically update the right label.

```swift
struct ContentView: View {
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            // ...destinations
        }
        .trackScreenName(path: path)
    }
}
```

#### 3. Sheet / Tab / Cover — explicit tracking

For screens outside the NavigationStack path, declare the name explicitly:

```swift
.sheet(isPresented: $showSheet) {
    SheetView()
        .trackScreenName("StandardSheet")
}

.fullScreenCover(isPresented: $showCover) {
    CoverView()
        .trackScreenName("FullScreenCover")
}

TabView {
    HomeView()
        .trackScreenName("Tab.Home")
        .tabItem { Label("Home", systemImage: "house") }
}
```

Stack-friendly — when a sheet is on screen, its name takes precedence; on dismissal the previous value is automatically restored.

<br>

## Configuration

### Configuration

Customize the overlay appearance via `start { config in ... }`:

```swift
ScreenNameViewer.start { config in
    // Left label — UIViewController name
    config.viewController.textColor = .white
    config.viewController.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    config.viewController.textSize = 12
    config.viewController.enabled = true

    // Right label — NavigationStack route
    config.route.textColor = .systemYellow
    config.route.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    config.route.textSize = 12

    // Vertical position (top / bottom). Horizontal placement is fixed (left/right).
    config.verticalPosition = .top
}
```

<br>

### Configuration Options

- **viewController** / **route**: Style for each label
  - `textColor`: Text color
  - `backgroundColor`: Background color
  - `textSize`: Text size
  - `enabled`: Whether the label is visible
  - `paddingHorizontal` / `paddingVertical`: Internal padding
  - `cornerRadius`: Corner radius

- **verticalPosition**: Vertical position of the overlay (`.top` / `.bottom`)
  Horizontal position is fixed: viewController on the left, route on the right

<br>

## How it works

The name shown in the overlay is normalized to always be a symbol from the user's own codebase:

1. `String(describing: type(of: vc))` → full name (e.g., `MyApp.HomeViewController`, `UIHostingController<...>`)
2. Strip generic `<...>` parameters → `UIHostingController`
3. Strip module prefix → `HomeViewController`
4. Returns `nil` if the result is an Apple framework base class (`UIViewController`, `UINavigationController`, `UITabBarController`, `UIHostingController`, etc.) — the label is auto-hidden

→ The text shown in the overlay is always grep-able. Use `Open Quickly` (⇧⌘O) or grep to jump straight to the file.

<br>

## Sample app

A demo app is included in the repository:

- **SwiftUI**: Basic / Deep Navigation / Sheet / Full-Screen Cover / TabView
- **UIKit**: `UINavigationController` / `UITabBarController` / Modal / Container ViewController

Open `ScreenNameViewer-For-iOS.xcodeproj` and run to see the library in action across each case.

<br>

## Architecture

```mermaid
classDiagram
    direction TB

    class ScreenNameViewer {
        <<enum>>
        +start(configure)$
        +stop()$
    }

    class Configuration {
        <<struct>>
        +viewController: LabelStyle
        +route: LabelStyle
        +verticalPosition: VerticalPosition
    }

    class LabelStyle {
        <<struct>>
        +textColor: UIColor
        +backgroundColor: UIColor
        +textSize: CGFloat
        +enabled: Bool
    }

    class TrackScreenNameModifier {
        <<ViewModifier>>
        -id: UUID
        -routeName: String?
    }

    class Tracker {
        <<MainActor singleton>>
        +shared: Tracker$
        -isRunning: Bool
        +start(config)
        +stop()
        +handleViewDidAppear(vc)
        +handleViewDidDisappear(vc)
        +setRoute(id, name)
        +removeRoute(id)
    }

    class VCStack {
        <<struct>>
        -entries: WeakVC[]
        +push(vc)
        +remove(vc)
        +top: UIViewController?
    }

    class RouteRegistry {
        <<struct>>
        -entries: tuples
        +set(id, name)
        +remove(id)
        +current: String?
    }

    class RenderScheduler {
        <<MainActor>>
        -scheduled: Bool
        +schedule(action)
    }

    class Swizzler {
        <<enum>>
        +swizzleOnce()$
    }

    class VCNameFormatter {
        <<enum>>
        +names(for: vc)$ Names?
    }

    class Names {
        <<struct>>
        +display: String
        +full: String
    }

    class OverlayManager {
        <<MainActor>>
        +render(vc, route, config)
        +removeAll()
        +topVisibleViewController(in)$
    }

    class SceneOverlay {
        <<MainActor>>
        +update(vc, route, config)
        +handlePotentialLabelTap(at, fromWindow)
        +tearDown()
    }

    class OverlayWindow {
        <<UIWindow>>
        +update(...)
        +handlePotentialLabelTap(at)
        +hitTest()
    }

    class OverlayViewController {
        <<UIViewController>>
        +update(...)
        +handlePotentialLabelTap(at)
        -showToast(text)
    }

    class AppWindowTapInstaller {
        <<NSObject + UIGestureDelegate>>
        +onTap: closure
        +installIfNeeded(on: window)
    }

    Configuration *-- LabelStyle
    VCNameFormatter ..> Names

    ScreenNameViewer ..> Tracker
    TrackScreenNameModifier ..> Tracker

    Swizzler ..> Tracker

    Tracker *-- VCStack
    Tracker *-- RouteRegistry
    Tracker *-- RenderScheduler
    Tracker *-- OverlayManager
    Tracker ..> Swizzler

    OverlayManager *-- SceneOverlay
    OverlayManager *-- AppWindowTapInstaller

    SceneOverlay *-- OverlayWindow
    SceneOverlay ..> VCNameFormatter

    OverlayWindow *-- OverlayViewController
```

**Notation**

- `*--` composition (the parent owns the child instance directly)
- `..>` dependency (calls only, no ownership)
- `<<...>>` stereotype (struct / enum / MainActor class / UIWindow, etc.)
- `+` public, `-` private, `$` static

<br>

## Contributors

<!-- readme: collaborators,contributors -start -->
<table>
    <tbody>
        <tr>
            <td align="center">
                <a href="https://github.com/dongx0915">
                    <img src="https://avatars.githubusercontent.com/u/63500239?v=4" width="100;" alt="dongx0915"/>
                    <br />
                    <sub><b>Donghyeon Kim</b></sub>
                </a>
            </td>
        </tr>
    <tbody>
</table>
<!-- readme: collaborators,contributors -end -->
