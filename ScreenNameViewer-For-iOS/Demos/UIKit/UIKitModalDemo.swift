import SwiftUI
import UIKit

struct UIKitModalDemo: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIKitModalRootViewController {
        UIKitModalRootViewController()
    }

    func updateUIViewController(_ uiViewController: UIKitModalRootViewController, context: Context) {}
}

final class UIKitModalRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let label = UILabel()
        label.text = "Modal Presentation"
        label.font = .preferredFont(forTextStyle: .title2)
        stack.addArrangedSubview(label)

        addButton(stack, title: "Present Page Sheet", action: #selector(presentPageSheet))
        addButton(stack, title: "Present Form Sheet", action: #selector(presentFormSheet))
        addButton(stack, title: "Present Full Screen", action: #selector(presentFullScreen))

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func addButton(_ stack: UIStackView, title: String, action: Selector) {
        let btn = UIButton(type: .system)
        btn.configuration = .bordered()
        btn.setTitle(title, for: .normal)
        btn.addTarget(self, action: action, for: .touchUpInside)
        stack.addArrangedSubview(btn)
    }

    @objc private func presentPageSheet() {
        present(UIKitModalContentViewController(style: .pageSheet), animated: true)
    }

    @objc private func presentFormSheet() {
        present(UIKitModalContentViewController(style: .formSheet), animated: true)
    }

    @objc private func presentFullScreen() {
        present(UIKitModalContentViewController(style: .fullScreen), animated: true)
    }

    private func present(_ vc: UIViewController, animated: Bool) {
        if let style = (vc as? UIKitModalContentViewController)?.preferred {
            vc.modalPresentationStyle = style
        }
        super.present(vc, animated: animated)
    }
}

final class UIKitModalContentViewController: UIViewController {

    let preferred: UIModalPresentationStyle

    init(style: UIModalPresentationStyle) {
        self.preferred = style
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = style
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal.withAlphaComponent(0.15)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let label = UILabel()
        label.text = "UIKitModalContentViewController"
        label.font = .preferredFont(forTextStyle: .headline)
        stack.addArrangedSubview(label)

        let detail = UILabel()
        detail.text = "style: \(String(describing: preferred))"
        detail.font = .preferredFont(forTextStyle: .footnote)
        detail.textColor = .secondaryLabel
        stack.addArrangedSubview(detail)

        let dismissBtn = UIButton(type: .system)
        dismissBtn.configuration = .borderedProminent()
        dismissBtn.setTitle("Dismiss", for: .normal)
        dismissBtn.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        stack.addArrangedSubview(dismissBtn)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}
