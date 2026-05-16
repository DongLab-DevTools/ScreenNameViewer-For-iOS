import SwiftUI
import ScreenNameViewer

struct PathlessValueNavigationDemo: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Go to screen 1", value: "1")
                NavigationLink("Go to screen 2", value: "2")
                NavigationLink("Go to settings", value: "settings")
            }
            .navigationTitle("Pathless Value")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .navigationDestinationWithScreenName(for: String.self) { value in
                PathlessValueDestination(value: value)
            }
        }
    }
}

private struct PathlessValueDestination: View {
    let value: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 56))

            Text("This is screen number \(value)")
                .font(.title2)

            if value != "nested" {
                NavigationLink("Go deeper", value: "nested")
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Value \(value)")
    }

    private var iconName: String {
        switch value {
        case "1", "2":
            "\(value).circle"
        case "settings":
            "gearshape"
        default:
            "square.stack.3d.up"
        }
    }
}
