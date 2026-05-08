import SwiftUI

struct BasicNavigationDemo: View {
    var body: some View {
        List {
            ForEach(1..<6) { id in
                NavigationLink("Open Detail #\(id)", value: DemoRoute.swiftUIBasicDetail(id: id))
            }
        }
        .navigationTitle("Basic Navigation")
    }
}

struct BasicDetailScreen: View {
    let id: Int
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "\(id).circle")
                .font(.system(size: 64))
            Text("Detail #\(id)")
                .font(.title2)
            Text("Pushed onto the root NavigationStack.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Detail \(id)")
    }
}
