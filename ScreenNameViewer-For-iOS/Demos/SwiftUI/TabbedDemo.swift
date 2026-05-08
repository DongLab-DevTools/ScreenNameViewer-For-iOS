import SwiftUI
import ScreenNameViewer

struct TabbedDemo: View {

    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            TabContent(title: "Home", icon: "house", color: .blue)
                .trackScreenName("Tab.Home")
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            TabContent(title: "Browse", icon: "magnifyingglass", color: .green)
                .trackScreenName("Tab.Browse")
                .tabItem { Label("Browse", systemImage: "magnifyingglass") }
                .tag(1)

            TabContent(title: "Profile", icon: "person.crop.circle", color: .pink)
                .trackScreenName("Tab.Profile")
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(2)
        }
        .navigationTitle("Tabbed Navigation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TabContent: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(color)
            Text(title).font(.title2)
            Text("Switch tabs and watch the route label update.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
