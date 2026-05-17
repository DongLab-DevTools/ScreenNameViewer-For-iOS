import SwiftUI

public extension View {

    /// `NavigationStack(path:)` 배열로 현재 네비게이션 라우트를 오버레이에 표시
    /// 배열의 마지막 요소가 현재 라우트 이름
    ///
    /// RELEASE 빌드에서 무효 (path.last 변환도 RELEASE 에선 수행 안 함)
    func trackScreenName<H: Hashable>(path: [H]) -> some View {
        #if DEBUG
        let name = path.last.map { String(describing: $0) }
        #else
        let name: String? = nil
        #endif
        return modifier(_TrackScreenNameModifier(routeName: name))
    }

    /// 명시적인 라우트 이름을 오버레이에 표시 (nil 전달 시 라벨 비움)
    ///
    /// 스택 친화 — 다른 `.trackScreenName(...)`을 중첩하면(예: `.sheet`, `TabView` 자식)
    /// 화면에 떠 있는 동안 이 값 덮어쓰기, 사라지면 이전 값 자동 복원
    ///
    /// RELEASE 빌드에서 무효
    func trackScreenName(_ routeName: String?) -> some View {
        modifier(_TrackScreenNameModifier(routeName: routeName))
    }

    /// `NavigationStack` path 없이 `NavigationLink(value:)`를 쓰는 화면의 destination 이름을 자동 표시
    ///
    /// destination closure가 받은 value를 이용해 `"File.swift : value: ..."` 형식의 라우트 이름을 만듦
    ///
    /// RELEASE 빌드에서 무효 (fileID 파싱 / value String 변환 RELEASE 에선 수행 안 함)
    func navigationDestinationWithScreenName<D, C>(
        for data: D.Type,
        fileID: StaticString = #fileID,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View where D: Hashable, C: View {
        #if DEBUG
        let screenFile = _screenFileName(fileID)
        #endif
        return navigationDestination(for: data) { value in
            #if DEBUG
            let routeName: String? = "\(screenFile) : value: \(value)"
            #else
            let routeName: String? = nil
            #endif
            return destination(value).trackScreenName(routeName)
        }
    }
}

#if DEBUG
private func _screenFileName(_ fileID: StaticString) -> String {
    let raw = "\(fileID)"
    return raw.split(separator: "/").last.map(String.init) ?? raw
}
#endif

private struct _TrackScreenNameModifier: ViewModifier {

    let routeName: String?

    // 모디파이어 인스턴스의 안정적 식별자
    // Tracker가 (id, name) 페어 set 유지 — appear에서 등록 / change에서 갱신 / disappear에서 제거
    // 시트 dismiss / 탭 전환 시 자기 항목만 정확히 빠짐
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
