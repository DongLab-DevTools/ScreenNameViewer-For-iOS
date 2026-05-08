// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ScreenNameViewer",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ScreenNameViewer",
            targets: ["ScreenNameViewer"]
        ),
    ],
    targets: [
        .target(
            name: "ScreenNameViewer",
            path: "Sources/ScreenNameViewer"
        ),
    ]
)
