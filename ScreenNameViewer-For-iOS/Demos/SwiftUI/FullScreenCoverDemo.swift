import SwiftUI
import ScreenNameViewer

struct FullScreenCoverDemo: View {

    @State private var showCover = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Full-screen modal that covers the whole window.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button("Present Full-Screen Cover") { showCover = true }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Full-Screen Cover")
        .fullScreenCover(isPresented: $showCover) {
            FullScreenCoverContent()
                .trackScreenName("FullScreenCoverContent")
        }
    }
}

private struct FullScreenCoverContent: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.indigo, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "rectangle.fill.on.rectangle.fill")
                    .font(.system(size: 64))
                Text("Full-Screen Cover")
                    .font(.largeTitle.bold())
                Button("Dismiss") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(.purple)
            }
            .foregroundStyle(.white)
        }
    }
}
