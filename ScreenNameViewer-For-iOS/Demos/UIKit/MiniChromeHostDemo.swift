import SwiftUI
import UIKit

/// 화면 위에 항상 떠있는 mini-player chrome (passthrough child VC) 케이스 데모
///
/// 실제 사용 예: Tving 앱의 `ChromecastPlayerViewController` — 부모 화면의 child로 부착되어
/// 모든 화면 위에 떠있고 자기 본체 영역 외엔 터치 통과
///
/// 라이브러리 측에서 `Configuration.excludedClassNames`에 chrome 클래스명을 추가하면
/// 추적 대상에서 제외되어 본래 화면의 라벨이 그대로 유지됨
struct MiniChromeHostDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MiniChromeHostViewController {
        MiniChromeHostViewController()
    }

    func updateUIViewController(_ uiViewController: MiniChromeHostViewController, context: Context) {}
}

final class MiniChromeHostViewController: UIViewController {

    private let chrome = MiniPlayerChromeViewController()
    private var didAttachChrome = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let title = UILabel()
        title.text = "MiniChromeHost"
        title.font = .preferredFont(forTextStyle: .largeTitle)
        title.translatesAutoresizingMaskIntoConstraints = false

        let body = UILabel()
        body.text = "이 화면은 항상 'MiniPlayerChrome' child VC를 부착하고 있음.\nexcludedClassNames에 등록되어 있어 라벨은 'MiniChromeHost' 유지."
        body.numberOfLines = 0
        body.textAlignment = .center
        body.font = .preferredFont(forTextStyle: .callout)
        body.textColor = .secondaryLabel
        body.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [title, body])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attachChromeIfNeeded()
    }

    private func attachChromeIfNeeded() {
        guard !didAttachChrome else { return }
        didAttachChrome = true

        addChild(chrome)
        chrome.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chrome.view)
        NSLayoutConstraint.activate([
            chrome.view.topAnchor.constraint(equalTo: view.topAnchor),
            chrome.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chrome.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chrome.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        chrome.didMove(toParent: self)
    }
}

/// 항상 떠있는 mini-player chrome — 본체(하단 막대) 외 영역은 hitTest 통과
final class MiniPlayerChromeViewController: UIViewController {

    override func loadView() {
        self.view = PassthroughView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let bar = UIView()
        bar.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
        bar.layer.cornerRadius = 12
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)

        let barLabel = UILabel()
        barLabel.text = "MiniPlayerChrome — excludedClassNames에 등록됨"
        barLabel.textColor = .white
        barLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        barLabel.textAlignment = .center
        barLabel.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(barLabel)

        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            bar.heightAnchor.constraint(equalToConstant: 56),

            barLabel.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 12),
            barLabel.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -12),
            barLabel.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
        ])
    }
}

private final class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view === self ? nil : view
    }
}
