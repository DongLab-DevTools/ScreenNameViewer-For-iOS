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
