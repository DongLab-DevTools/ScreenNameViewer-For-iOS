import SwiftUI
import UIKit

struct UIKitTabBarDemo: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UITabBarController {
        let tab = UITabBarController()
        let vcs: [UIViewController] = [
            wrap(UIKitTabHomeViewController(), title: "Home", icon: "house"),
            wrap(UIKitTabBrowseViewController(), title: "Browse", icon: "magnifyingglass"),
            wrap(UIKitTabProfileViewController(), title: "Profile", icon: "person.crop.circle"),
        ]
        tab.viewControllers = vcs
        return tab
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {}

    private func wrap(_ vc: UIViewController, title: String, icon: String) -> UIViewController {
        vc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), tag: 0)
        vc.title = title
        return vc
    }
}

private func makeContent(text: String, color: UIColor) -> UIViewController {
    let vc = UIViewController()
    vc.view.backgroundColor = .systemBackground
    let label = UILabel()
    label.text = text
    label.font = .preferredFont(forTextStyle: .title1)
    label.textColor = color
    label.translatesAutoresizingMaskIntoConstraints = false
    vc.view.addSubview(label)
    NSLayoutConstraint.activate([
        label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
    ])
    return vc
}

final class UIKitTabHomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        attachLabel("Home Tab", color: .systemBlue)
    }
}

final class UIKitTabBrowseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        attachLabel("Browse Tab", color: .systemGreen)
    }
}

final class UIKitTabProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        attachLabel("Profile Tab", color: .systemPink)
    }
}

private extension UIViewController {
    func attachLabel(_ text: String, color: UIColor) {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
