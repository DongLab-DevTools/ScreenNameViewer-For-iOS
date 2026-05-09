import Foundation

/// 화면 이름 오버레이의 공개 진입점
///
/// 앱 시작 시 `ScreenNameViewer.start()` 1회 호출만으로 동작 — 이후 화면에
/// 나타나는 모든 `UIViewController`가 터치 통과 오버레이 윈도우에 표시됨
///
/// RELEASE 빌드에서는 이 타입의 모든 API가 빈 함수로 컴파일되어 `DEBUG`
/// 플래그가 없으면 런타임 비용 0
public enum ScreenNameViewer {

    /// 추적 시작 + 오버레이 표시
    ///
    /// 여러 번 호출해도 안전 — 가장 최근 호출의 설정이 적용됨. RELEASE
    /// 에서는 무효
    @MainActor
    public static func start(_ configure: (inout Configuration) -> Void = { _ in }) {
        #if DEBUG
        var config = Configuration()
        configure(&config)
        Tracker.shared.start(configuration: config)
        #endif
    }

    /// 오버레이 숨김 + 애플리케이션 레벨 라이프사이클 이벤트 수신 중단
    ///
    /// 메서드 swizzling 자체는 되돌리지 않음(안전한 방법 없음) — 이후 후크는
    /// 단일 boolean 체크로 축소. RELEASE에서는 무효
    @MainActor
    public static func stop() {
        #if DEBUG
        Tracker.shared.stop()
        #endif
    }
}
