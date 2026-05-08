#if DEBUG
import UIKit

@MainActor
final class OverlayViewController: UIViewController {

    private let stack = UIStackView()
    private let vcLabel = PaddedLabel()
    private let routeLabel = PaddedLabel()

    private var positionConstraints: [NSLayoutConstraint] = []
    private var lastAppliedVerticalPosition: Configuration.VerticalPosition?
    private var lastAppliedHorizontalPosition: Configuration.HorizontalPosition?

    override func loadView() {
        let v = PassthroughView()
        v.backgroundColor = .clear
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isUserInteractionEnabled = false

        view.addSubview(stack)
        stack.addArrangedSubview(vcLabel)
        stack.addArrangedSubview(routeLabel)
    }

    func update(viewControllerName: String?, routeName: String?, configuration: Configuration) {
        applyPositionIfNeeded(
            vertical: configuration.verticalPosition,
            horizontal: configuration.horizontalPosition
        )

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

    private func applyPositionIfNeeded(
        vertical: Configuration.VerticalPosition,
        horizontal: Configuration.HorizontalPosition
    ) {
        if vertical == lastAppliedVerticalPosition && horizontal == lastAppliedHorizontalPosition {
            return
        }
        lastAppliedVerticalPosition = vertical
        lastAppliedHorizontalPosition = horizontal

        NSLayoutConstraint.deactivate(positionConstraints)
        positionConstraints.removeAll()

        let g = view.safeAreaLayoutGuide
        var c: [NSLayoutConstraint] = []

        switch vertical {
        case .top:
            c.append(stack.topAnchor.constraint(equalTo: g.topAnchor, constant: 4))
        case .bottom:
            c.append(stack.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -4))
        }

        switch horizontal {
        case .leading:
            c.append(stack.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 8))
            stack.alignment = .leading
        case .trailing:
            c.append(stack.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -8))
            stack.alignment = .trailing
        case .center:
            c.append(stack.centerXAnchor.constraint(equalTo: g.centerXAnchor))
            stack.alignment = .center
        }

        NSLayoutConstraint.activate(c)
        positionConstraints = c
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
