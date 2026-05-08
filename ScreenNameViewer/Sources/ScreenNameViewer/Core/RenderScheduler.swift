#if DEBUG
import Foundation

/// 호출 합치기 — 다음 메인 스레드 차례에 1회만 실행
///
/// 탭 전환처럼 onAppear/onDisappear 연속 발생 시 중간 빈 화면 깜빡임 방지
/// 첫 호출의 클로저만 큐 등록, 이후 호출은 무시
/// 클로저 내부는 캡처값 대신 실행 시점의 최신 상태를 직접 조회
@MainActor
final class RenderScheduler {

    private var scheduled = false

    func schedule(_ action: @escaping () -> Void) {
        guard !scheduled else { return }
        scheduled = true
        DispatchQueue.main.async { [weak self] in
            self?.scheduled = false
            action()
        }
    }
}
#endif
