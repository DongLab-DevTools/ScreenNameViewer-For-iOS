import Foundation

/// 화면 이름 오버레이의 공개 진입점
///
/// 앱 시작 시 `ScreenNameViewer.install()` 1회 호출만으로 동작 — 이후 화면에
/// 나타나는 모든 `UIViewController`가 터치 통과 오버레이 윈도우에 표시됨
///
/// RELEASE 빌드에서는 이 타입의 모든 API가 빈 함수로 컴파일되어 `DEBUG`
/// 플래그가 없으면 런타임 비용 0
public enum ScreenNameViewer {

    /// 라이브러리 설치 — 메서드 swizzling 1회 + 오버레이 표시
    ///
    /// 런타임 on/off 가 아니라 앱 부팅 시 1회 호출하는 모델. 사용자 설정의
    /// 토글 상태는 `enabled` 로 주입 — 토글 변경 후 재시작 시 새 값이 반영됨
    ///
    /// - Parameter enabled: false 면 swizzling/오버레이 모두 건너뜀. 사용자
    ///   설정에서 디버그 오버레이를 끈 상태와 매칭
    /// - Parameter configure: 옵션 커스터마이즈 클로저
    ///
    /// 여러 번 호출해도 안전 — 가장 최근 호출의 설정이 적용됨. RELEASE
    /// 에서는 무효
    @MainActor
    public static func install(
        enabled: Bool = true,
        _ configure: (inout Configuration) -> Void = { _ in }
    ) {
        #if DEBUG
        guard enabled else { return }
        var config = Configuration()
        configure(&config)
        Tracker.shared.start(configuration: config)
        #endif
    }
}
