//
//  ContentView.swift
//  ScreenNameViewer-For-iOS
//

import SwiftUI
import ScreenNameViewer

struct ContentView: View {

    @State private var path: [DemoRoute] = []
    @State private var showPathlessValueDemo = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("SwiftUI") {
                    row("Basic NavigationStack",   icon: "arrow.right.circle",       value: .swiftUIBasicNavigation)
                    row("Deep NavigationStack",    icon: "square.stack.3d.up",       value: .swiftUIDeepNavigation)
                    sheetRow("Pathless Value Navigation (sheet)", icon: "chevron.right.2") {
                        showPathlessValueDemo = true
                    }
                    row("Sheet",                   icon: "rectangle.portrait.bottomthird.inset.filled", value: .swiftUISheet)
                    row("Full-Screen Cover",       icon: "rectangle.fill.on.rectangle.fill",            value: .swiftUIFullScreenCover)
                    row("TabView + Tabs",          icon: "square.grid.2x2",          value: .swiftUITabbed)
                }

                Section("UIKit") {
                    row("UINavigationController",  icon: "chevron.right.square",     value: .uikitNavigationController)
                    row("UITabBarController",      icon: "rectangle.bottomthird.inset.filled",          value: .uikitTabBarController)
                    row("Modal Presentation",      icon: "rectangle.center.inset.filled",               value: .uikitModalPresentation)
                    row("Container ViewController", icon: "square.split.2x1",        value: .uikitContainerViewController)
                }
            }
            .navigationTitle("ScreenNameViewer")
            .navigationDestination(for: DemoRoute.self) { route in
                destination(for: route)
            }
        }
        .trackScreenName(path: path)
        .sheet(isPresented: $showPathlessValueDemo) {
            PathlessValueNavigationDemo()
        }
    }

    private func row(_ title: String, icon: String, value: DemoRoute) -> some View {
        NavigationLink(value: value) {
            Label(title, systemImage: icon)
        }
    }

    private func sheetRow(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: icon)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func destination(for route: DemoRoute) -> some View {
        switch route {
        case .swiftUIBasicNavigation:
            BasicNavigationDemo()
        case .swiftUIDeepNavigation:
            DeepNavigationDemo()
        case .swiftUISheet:
            SheetDemo()
        case .swiftUIFullScreenCover:
            FullScreenCoverDemo()
        case .swiftUITabbed:
            TabbedDemo()

        case .swiftUIBasicDetail(let id):
            BasicDetailScreen(id: id)
        case .swiftUIDeepLevel(let level):
            DeepLevelScreen(level: level)

        case .uikitNavigationController:
            UIKitNavigationDemo()
                .ignoresSafeArea()
                .navigationTitle("UINavigationController")
                .navigationBarTitleDisplayMode(.inline)
        case .uikitTabBarController:
            UIKitTabBarDemo()
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("UITabBarController")
                .navigationBarTitleDisplayMode(.inline)
        case .uikitModalPresentation:
            UIKitModalDemo()
                .navigationTitle("Modal Presentation")
                .navigationBarTitleDisplayMode(.inline)
        case .uikitContainerViewController:
            UIKitContainerDemo()
                .navigationTitle("Container ViewController")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
