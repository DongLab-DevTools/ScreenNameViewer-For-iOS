//
//  ContentView.swift
//  ScreenNameViewer-For-iOS
//

import SwiftUI
import ScreenNameViewer

enum DemoRoute: Hashable {
    case detail(id: Int)
    case settings
}

struct ContentView: View {

    @State private var path: [DemoRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: DemoRoute.self) { route in
                    switch route {
                    case .detail(let id): DetailView(id: id)
                    case .settings:       SettingsView()
                    }
                }
        }
        // One-liner that mirrors Compose's `ScreenNameTracker(navController)`.
        .trackScreenName(path: path)
    }
}

private struct HomeView: View {
    var body: some View {
        List {
            NavigationLink("Detail #1", value: DemoRoute.detail(id: 1))
            NavigationLink("Detail #2", value: DemoRoute.detail(id: 2))
            NavigationLink("Settings",  value: DemoRoute.settings)
        }
        .navigationTitle("Home")
    }
}

private struct DetailView: View {
    let id: Int
    var body: some View {
        Text("Detail #\(id)")
            .navigationTitle("Detail \(id)")
    }
}

private struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}

#Preview {
    ContentView()
}
