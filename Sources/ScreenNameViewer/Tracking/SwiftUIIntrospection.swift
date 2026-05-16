#if DEBUG
import UIKit

/// SwiftUI `UIHostingController` 류가 자기 호스팅 중인 사용자 정의 View 의 타입명을 노출하지 않을 때,
/// `Mirror` 로 내부 트리를 따라가 첫 사용자 타입을 추출
///
/// 사용 시점: `VCNameFormatter.names(for:)` 가 nil 반환 (= SwiftUI 내부 베이스 클래스로 판정) 했을 때
///
/// 안전성 계약:
/// - 어떤 입력이 와도 절대 크래시하지 않음
/// - `value(forKey:)` 같은 KVC 미사용 (NSException 던질 수 있어 Swift try-catch 불가)
/// - 강제 unwrap / 강제 캐스팅 미사용
/// - 재귀 깊이 제한으로 무한 루프 방지
/// - 항상 `String?` 반환, 어떤 실패든 `nil`
enum SwiftUIIntrospection {

    private static let maxDepth = 8

    /// SwiftUI 호스트가 의심되는 `vc` 의 내부 root view 에서 첫 사용자 타입명을 추출
    /// 못 찾으면 nil
    static func extractRootName(from vc: UIViewController) -> String? {
        guard let host = findChild(of: vc, named: "host", maxClassDepth: 6) else { return nil }
        guard let rootView = findChild(of: host, named: "_rootView", maxClassDepth: 3)
            ?? findChild(of: host, named: "rootView", maxClassDepth: 3) else { return nil }
        return firstUserType(in: rootView, depth: 0)
    }

    /// Mirror 의 superclass chain 까지 따라가며 이름이 일치하는 첫 자식의 value 반환
    /// `vc` / `host` 가 SwiftUI 내부 클래스의 깊은 서브클래스인 경우 대비
    private static func findChild(of object: Any, named: String, maxClassDepth: Int) -> Any? {
        var mirror: Mirror? = Mirror(reflecting: object)
        var depth = 0
        while let m = mirror, depth <= maxClassDepth {
            for child in m.children where child.label == named {
                return child.value
            }
            mirror = m.superclassMirror
            depth += 1
        }
        return nil
    }

    /// `view` (보통 SwiftUI View 구조체) 의 타입명을 파싱해서 첫 사용자 타입명 반환
    /// `AnyView` 면 그 안의 `storage` 의 제너릭 파라미터까지 파고듦
    /// 깊이 제한 도달하거나 사용자 타입 못 찾으면 nil
    private static func firstUserType(in view: Any, depth: Int) -> String? {
        guard depth < maxDepth else { return nil }

        // `String(reflecting:)` 은 `String(describing:)` 와 달리 fully-qualified 타입명을 줌
        // 예: "SwiftUI.AnyViewStorage<SwiftUI.ModifiedContent<MyApp.HomeView, ...>>"
        let typeName = String(reflecting: type(of: view))

        // path-based `.navigationDestination(for:)` 의 destination 호스트 — 활성 분기 식별 불가
        // (`SwiftUI.ParameterizedLazyView<Value, Content>` 안의 Content 는 `_ConditionalContent` 로
        // 모든 가능한 destination 분기가 union 되어있어 런타임 없이 결정 불가)
        if typeName.contains(".ParameterizedLazyView<") {
            return nil
        }

        if let user = firstUserType(inQualifiedTypeName: typeName) {
            return user
        }

        // view 가 컨테이너성 (AnyView, ModifiedContent 등) 일 가능성 — 자식 탐색
        let mirror = Mirror(reflecting: view)
        for child in mirror.children {
            let childTypeName = String(reflecting: type(of: child.value))
            if childTypeName.contains(".ParameterizedLazyView<") {
                continue
            }
            if let user = firstUserType(inQualifiedTypeName: childTypeName) {
                return user
            }
            if shouldRecurse(into: child.label) {
                if let user = firstUserType(in: child.value, depth: depth + 1) {
                    return user
                }
            }
        }

        return nil
    }

    private static func shouldRecurse(into label: String?) -> Bool {
        guard let label else { return false }
        return ["storage", "content", "view", "modifier", "rootView"].contains(label)
    }

    /// Fully-qualified 타입명 (예: `SwiftUI.AnyViewStorage<SwiftUI.ModifiedContent<MyApp.HomeView, ...>>`)
    /// 에서 `Module.Symbol[.Nested[.Deeper...]]` dot-chain 들을 스캔. 첫 번째 토큰(모듈) 이
    /// `frameworkModules` 에도 없고 `_` prefix 도 아니면 사용자 코드로 판정, 그 다음 토큰
    /// (top-level 타입) 을 반환.
    ///
    /// 중요 — `SwiftUI.NavigationState.StackContent.Key` 같이 4단 nested 인 경우 모듈이 `SwiftUI`
    /// 이므로 **chain 전체를 한 덩어리로 스킵** 해야 함. 그렇지 않으면 `StackContent` 가 user 모듈로,
    /// `Key` 가 user 타입으로 잘못 추출됨.
    private static func firstUserType(inQualifiedTypeName name: String) -> String? {
        var i = name.startIndex
        while i < name.endIndex {
            guard isIdentStart(name[i]) else {
                i = name.index(after: i)
                continue
            }

            // dot-chain 토큰들을 읽음 — Module.Type.Nested.Deeper...
            var chain: [String] = []
            var k = i
            while k < name.endIndex, isIdentStart(name[k]) {
                var end = k
                while end < name.endIndex, isIdentCont(name[end]) {
                    end = name.index(after: end)
                }
                chain.append(String(name[k..<end]))
                k = end
                // 다음에 '.' 이고 그 다음이 또 식별자면 chain 계속
                if k < name.endIndex, name[k] == "." {
                    let after = name.index(after: k)
                    if after < name.endIndex, isIdentStart(name[after]) {
                        k = after
                        continue
                    }
                }
                break
            }

            // chain 의 첫 토큰이 모듈 — 사용자 모듈이면 두 번째 토큰(top-level 타입)이 답
            if chain.count >= 2 {
                let module = chain[0]
                if !module.hasPrefix("_"),
                   !FrameworkModules.names.contains(module) {
                    return chain[1]
                }
            }
            i = k
        }
        return nil
    }

    private static func isIdentStart(_ c: Character) -> Bool {
        c.isLetter || c == "_"
    }

    private static func isIdentCont(_ c: Character) -> Bool {
        c.isLetter || c.isNumber || c == "_"
    }
}
#endif
