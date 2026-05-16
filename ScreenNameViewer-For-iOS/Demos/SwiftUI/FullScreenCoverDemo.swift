import SwiftUI
import ScreenNameViewer

struct FullScreenCoverDemo: View {

    @State private var showCover = false
    @State private var showUntrackedCover = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Full-screen modal that covers the whole window.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button("Present (with .trackScreenName)") { showCover = true }
                .buttonStyle(.borderedProminent)

            Button("Present (no tracker → fallback)") { showUntrackedCover = true }
                .buttonStyle(.bordered)

            Text("두 번째 버튼은 .trackScreenName을 안 붙입니다. iOS 26 SwiftUI는 PresentationHostingController<AnyView>로 type-erase 해서 라이브러리가 이름을 못 캐는 케이스 — 이때 라벨은 빈 채로 가지 않고 직전 화면(이 화면)의 라벨을 그대로 유지합니다.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Full-Screen Cover")
        .fullScreenCover(isPresented: $showCover) {
            FullScreenCoverContent(title: "FullScreenCoverContent")
                .trackScreenName("FullScreenCoverContent")
        }
        .fullScreenCover(isPresented: $showUntrackedCover) {
            FullScreenCoverContent(title: "(no tracker)")
        }
    }
}

private struct FullScreenCoverContent: View {
    let title: String
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
                Text(title)
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
