#if DEBUG
import SwiftUI

/// SwiftUIIntrospection 파서 검증용 mock View 들
struct MockHomeView: View {
    var body: some View { Text("home") }
}

struct MockSettingsView: View {
    var body: some View { Text("settings") }
}

struct MockGenericContainer<Content: View>: View {
    let content: Content
    var body: some View { content }
}
#endif
