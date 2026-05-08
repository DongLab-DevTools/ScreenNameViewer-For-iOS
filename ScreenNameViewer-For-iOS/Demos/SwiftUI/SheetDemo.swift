import SwiftUI
import ScreenNameViewer

struct SheetDemo: View {

    @State private var showFirst = false
    @State private var showSecond = false

    var body: some View {
        VStack(spacing: 16) {
            Button("Present Sheet") { showFirst = true }
                .buttonStyle(.borderedProminent)

            Button("Present Detents Sheet") { showSecond = true }
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Sheet")
        .sheet(isPresented: $showFirst) {
            SheetContent(title: "Standard Sheet")
                // Override the route name while this sheet is on screen.
                .trackScreenName("StandardSheet")
        }
        .sheet(isPresented: $showSecond) {
            SheetContent(title: "Detents Sheet (medium / large)")
                .presentationDetents([.medium, .large])
                .trackScreenName("DetentsSheet")
        }
    }
}

private struct SheetContent: View {
    let title: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2)
            Text("Sheets present a new UIHostingController; its viewDidAppear is captured by the swizzler.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Button("Dismiss") { dismiss() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}
