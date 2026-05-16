#if DEBUG
import UIKit

/// 화면 등장 순서대로 약한 참조로 보관하는 VC 스택
///
/// 가장 최근의 살아있는 항목이 현재 화면
/// push/remove 시 같은 VC의 기존 항목 + 해제된 항목 일괄 정리
/// 시트 dismiss / 탭 전환 / 네비 push·pop을 별도 분기 없이 처리
struct VCStack {

    private var entries: [WeakVC] = []

    mutating func push(_ vc: UIViewController) {
        let id = ObjectIdentifier(vc)
        entries.removeAll { $0.id == id || $0.value == nil }
        entries.append(WeakVC(vc))
    }

    mutating func remove(_ vc: UIViewController) {
        let id = ObjectIdentifier(vc)
        entries.removeAll { $0.id == id || $0.value == nil }
    }

    mutating func clear() {
        entries.removeAll()
    }

    /// 가장 최근에 등장한 살아있는 VC, 해제된 항목은 건너뜀
    var top: UIViewController? {
        for entry in entries.reversed() {
            if let vc = entry.value { return vc }
        }
        return nil
    }

    /// `predicate`가 true를 반환하는 첫 살아있는 VC를 위에서부터 찾아 반환
    /// — 이름 없는 SwiftUI 내부 호스트가 위에 쌓여도 그 밑의 의미있는 VC를 라벨에 노출하기 위해 사용
    func topMatching(_ predicate: (UIViewController) -> Bool) -> UIViewController? {
        for entry in entries.reversed() {
            if let vc = entry.value, predicate(vc) { return vc }
        }
        return nil
    }
}

private struct WeakVC {
    weak var value: UIViewController?
    let id: ObjectIdentifier
    init(_ vc: UIViewController) {
        self.value = vc
        self.id = ObjectIdentifier(vc)
    }
}
#endif
