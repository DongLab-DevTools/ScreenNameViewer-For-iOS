#if DEBUG
import Foundation

/// SwiftUI `.trackScreenName`이 push한 라우트 항목 정렬 set
///
/// 가장 최근에 등장한 항목의 이름이 현재 라우트
/// ID 기반 — 시트 dismiss / 탭 swap 시 자기 항목만 정확히 제거
/// "nil로 덮어쓰기" 같은 잡음 없이 실제로 떠 있는 라우트만 표시
struct RouteRegistry {

    private var entries: [(id: UUID, name: String?)] = []

    mutating func set(id: UUID, name: String?) {
        if let idx = entries.firstIndex(where: { $0.id == id }) {
            entries[idx].name = name
        } else {
            entries.append((id, name))
        }
    }

    mutating func remove(id: UUID) {
        entries.removeAll { $0.id == id }
    }

    mutating func clear() {
        entries.removeAll()
    }

    var current: String? {
        entries.last?.name
    }
}
#endif
