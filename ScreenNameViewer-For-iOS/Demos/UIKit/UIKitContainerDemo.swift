import SwiftUI
import UIKit

struct UIKitContainerDemo: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIKitContainerViewController {
        UIKitContainerViewController()
    }

    func updateUIViewController(_ uiViewController: UIKitContainerViewController, context: Context) {}
}

final class UIKitContainerViewController: UIViewController {

    private let segmented = UISegmentedControl(items: ["Left", "Right"])
    private let containerView = UIView()
    private let leftChild = UIKitContainerLeftViewController()
    private let rightChild = UIKitContainerRightViewController()
    private weak var currentChild: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(switchChild), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmented)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmented.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        show(leftChild)
    }

    @objc private func switchChild() {
        let next: UIViewController = segmented.selectedSegmentIndex == 0 ? leftChild : rightChild
        show(next)
    }

    private func show(_ child: UIViewController) {
        if currentChild === child { return }

        if let outgoing = currentChild {
            outgoing.willMove(toParent: nil)
            outgoing.view.removeFromSuperview()
            outgoing.removeFromParent()
        }

        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        child.didMove(toParent: self)
        currentChild = child
    }
}

final class UIKitContainerLeftViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange.withAlphaComponent(0.15)
        let label = UILabel()
        label.text = "Left Child"
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

final class UIKitContainerRightViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple.withAlphaComponent(0.15)
        let label = UILabel()
        label.text = "Right Child"
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .systemPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
