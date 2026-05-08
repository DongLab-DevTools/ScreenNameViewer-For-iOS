import SwiftUI

struct DeepNavigationDemo: View {
    var body: some View {
        DeepLevelScreen(level: 0)
            .navigationTitle("Deep Navigation")
    }
}

struct DeepLevelScreen: View {
    let level: Int

    var body: some View {
        VStack(spacing: 24) {
            Text("Level \(level)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(color(for: level))

            Text("Push deeper to see the route name update.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if level < 4 {
                NavigationLink("Push Level \(level + 1)", value: DemoRoute.swiftUIDeepLevel(level + 1))
                    .buttonStyle(.borderedProminent)
            } else {
                Text("Reached the deepest level.")
                    .font(.callout)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Level \(level)")
    }

    private func color(for level: Int) -> Color {
        [.blue, .purple, .pink, .orange, .red][min(level, 4)]
    }
}
