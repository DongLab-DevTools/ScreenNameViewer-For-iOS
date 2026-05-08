import SwiftUI

public extension View {

    /// `NavigationStack(path:)` 배열로 현재 네비게이션 라우트를 오버레이에
    /// 표시. 배열의 마지막 요소가 현재 라우트 이름으로 렌더링 대상
    ///
    /// RELEASE 빌드에서 무효
    func trackScreenName<H: Hashable>(path: [H]) -> some View {
        let name = path.last.map { String(describing: $0) }
        return modifier(_TrackScreenNameModifier(routeName: name))
    }

    /// 명시적인 라우트 이름을 오버레이에 표시. nil 전달 시 라우트 라벨 비움.
    /// 스택 친화 — 다른 `.trackScreenName(...)`을 중첩(예: `.sheet`나
    /// `TabView` 자식 뷰)하면 그게 화면에 떠 있는 동안 이 값 덮어쓰기,
    /// 사라지면 이전 값으로 자동 복원
    ///
    /// RELEASE 빌드에서 무효
    func trackScreenName(_ routeName: String?) -> some View {
        modifier(_TrackScreenNameModifier(routeName: routeName))
    }
}

private struct _TrackScreenNameModifier: ViewModifier {

    let routeName: String?

    // 이 모디파이어 인스턴스의 안정적 식별자. Tracker는 (id, name) 페어의
    // 정렬 set 유지 — onAppear에서 등록, onChange에서 갱신, onDisappear에서
    // 제거. 이 방식 덕에 시트 dismiss나 탭 전환 시 "nil로 덮어쓰기" 같은
    // 잘못된 호출에 휘둘리지 않고 화면에 실제로 떠 있는 항목만 정확히 표시
    @State private var id = UUID()

    @ViewBuilder
    func body(content: Content) -> some View {
        #if DEBUG
        if #available(iOS 17, *) {
            content
                .onAppear { Tracker.shared.setRoute(id: id, name: routeName) }
                .onChange(of: routeName) { _, new in
                    Tracker.shared.setRoute(id: id, name: new)
                }
                .onDisappear { Tracker.shared.removeRoute(id: id) }
        } else {
            content
                .onAppear { Tracker.shared.setRoute(id: id, name: routeName) }
                .onChange(of: routeName) { new in
                    Tracker.shared.setRoute(id: id, name: new)
                }
                .onDisappear { Tracker.shared.removeRoute(id: id) }
        }
        #else
        content
        #endif
    }
}
