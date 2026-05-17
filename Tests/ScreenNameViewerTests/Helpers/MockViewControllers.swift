#if DEBUG
import UIKit

/// 테스트용 사용자 코드 VC — VCNameFormatter 통과해야 함
final class MockUserViewController: UIViewController {}
final class MockUserSecondViewController: UIViewController {}

/// 컨테이너 자기 자신 — UINavigationController 사용자 서브클래스
final class MockUserNavigationController: UINavigationController {}

/// 컨테이너 자기 자신 — UITabBarController 사용자 서브클래스
final class MockUserTabBarController: UITabBarController {}

/// 다른 VC 안에 임베드되는 child 시나리오용
final class MockChildViewController: UIViewController {}
final class MockChromeViewController: UIViewController {}
#endif
