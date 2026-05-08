#if DEBUG
import UIKit

@MainActor
final class OverlayViewController: UIViewController {

    private let vcLabel = PaddedLabel()
    private let routeLabel = PaddedLabel()

    private var verticalConstraints: [NSLayoutConstraint] = []
    private var lastAppliedVerticalPosition: Configuration.VerticalPosition?

    override func loadView() {
        let v = PassthroughView()
        v.backgroundColor = .clear
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for label in [vcLabel, routeLabel] {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isUserInteractionEnabled = false
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            view.addSubview(label)
        }

        let g = view.safeAreaLayoutGuide

        // 수평 위치 고정 — vc 좌측 / route 우측, swap 불가
        NSLayoutConstraint.activate([
            vcLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 8),
            routeLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -8),
            // 두 라벨 겹침 방지 — 충돌 직전에 어느 한 쪽 먼저 truncate
            vcLabel.trailingAnchor.constraint(lessThanOrEqualTo: routeLabel.leadingAnchor, constant: -8),
        ])
    }

    func update(viewControllerName: String?, routeName: String?, configuration: Configuration) {
        applyVerticalPositionIfNeeded(configuration.verticalPosition)

        if configuration.viewController.enabled, let name = viewControllerName, !name.isEmpty {
            vcLabel.apply(text: name, style: configuration.viewController)
            vcLabel.isHidden = false
        } else {
            vcLabel.isHidden = true
        }

        if configuration.route.enabled, let name = routeName, !name.isEmpty {
            routeLabel.apply(text: name, style: configuration.route)
            routeLabel.isHidden = false
        } else {
            routeLabel.isHidden = true
        }
    }

    private func applyVerticalPositionIfNeeded(_ vertical: Configuration.VerticalPosition) {
        if vertical == lastAppliedVerticalPosition { return }
        lastAppliedVerticalPosition = vertical

        NSLayoutConstraint.deactivate(verticalConstraints)
        verticalConstraints.removeAll()

        let g = view.safeAreaLayoutGuide
        var c: [NSLayoutConstraint] = []

        switch vertical {
        case .top:
            c.append(vcLabel.topAnchor.constraint(equalTo: g.topAnchor, constant: 4))
            c.append(routeLabel.topAnchor.constraint(equalTo: g.topAnchor, constant: 4))
        case .bottom:
            c.append(vcLabel.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -4))
            c.append(routeLabel.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -4))
        }

        NSLayoutConstraint.activate(c)
        verticalConstraints = c
    }
}

@MainActor
private final class PassthroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}

@MainActor
private final class PaddedLabel: UILabel {

    private var contentInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)

    func apply(text: String, style: Configuration.LabelStyle) {
        self.text = text
        self.textColor = style.textColor
        self.backgroundColor = style.backgroundColor
        self.font = .systemFont(ofSize: style.textSize, weight: .medium)
        self.contentInsets = UIEdgeInsets(
            top: style.paddingVertical,
            left: style.paddingHorizontal,
            bottom: style.paddingVertical,
            right: style.paddingHorizontal
        )
        self.layer.cornerRadius = style.cornerRadius
        self.clipsToBounds = true
        self.numberOfLines = 1
        self.lineBreakMode = .byTruncatingMiddle
        self.isUserInteractionEnabled = false
        self.invalidateIntrinsicContentSize()
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(
            width: s.width + contentInsets.left + contentInsets.right,
            height: s.height + contentInsets.top + contentInsets.bottom
        )
    }
}
#endif
