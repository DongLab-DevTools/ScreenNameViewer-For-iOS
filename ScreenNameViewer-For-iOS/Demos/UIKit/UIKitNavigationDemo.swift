import SwiftUI
import UIKit

struct UIKitNavigationDemo: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: UIKitNavRootViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

final class UIKitNavRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nav Root"
        view.backgroundColor = .systemBackground

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let label = UILabel()
        label.text = "UINavigationController"
        label.font = .preferredFont(forTextStyle: .title2)
        stack.addArrangedSubview(label)

        for i in 1...3 {
            let btn = UIButton(type: .system)
            btn.configuration = .borderedProminent()
            btn.setTitle("Push Detail #\(i)", for: .normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(pushDetail(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func pushDetail(_ sender: UIButton) {
        let vc = UIKitNavDetailViewController(detailID: sender.tag)
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class UIKitNavDetailViewController: UIViewController {

    private let detailID: Int

    init(detailID: Int) {
        self.detailID = detailID
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail \(detailID)"
        view.backgroundColor = .systemGroupedBackground

        let label = UILabel()
        label.text = "UIKitNavDetailViewController #\(detailID)"
        label.font = .preferredFont(forTextStyle: .title3)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
