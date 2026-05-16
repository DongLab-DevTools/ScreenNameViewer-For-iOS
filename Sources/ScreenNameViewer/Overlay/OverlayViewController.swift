#if DEBUG
import UIKit

@MainActor
final class OverlayViewController: UIViewController {

    private let vcLabel = PaddedLabel()
    private let introspectedLabel = PaddedLabel()
    private let leftLabelStack = UIStackView()
    private let routeLabel = PaddedLabel()
    private let toastLabel = ToastLabel()

    // 탭 시 토스트로 표시할 풀네임 보관
    private var vcFullName: String?
    private var introspectedFullName: String?
    private var routeFullName: String?
    private var toastDismissWorkItem: DispatchWorkItem?

    private var verticalConstraints: [NSLayoutConstraint] = []
    private var lastAppliedVerticalPosition: Configuration.VerticalPosition?

    override func loadView() {
        let v = PassthroughView()
        v.backgroundColor = .clear
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for label in [vcLabel, introspectedLabel, routeLabel] {
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }

        // 좌측: vc / introspected 두 라벨을 stack 에 담아 hidden 시 자동 collapse
        leftLabelStack.axis = .vertical
        leftLabelStack.alignment = .leading
        leftLabelStack.spacing = 2
        leftLabelStack.translatesAutoresizingMaskIntoConstraints = false
        leftLabelStack.addArrangedSubview(vcLabel)
        leftLabelStack.addArrangedSubview(introspectedLabel)
        view.addSubview(leftLabelStack)

        routeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(routeLabel)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.alpha = 0
        view.addSubview(toastLabel)

        let g = view.safeAreaLayoutGuide

        // 수평: stack 좌측 / route 우측
        NSLayoutConstraint.activate([
            leftLabelStack.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 8),
            leftLabelStack.trailingAnchor.constraint(lessThanOrEqualTo: routeLabel.leadingAnchor, constant: -8),
            routeLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -8),

            // 토스트 — 하단 중앙 고정, 좌우 16 패딩
            toastLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -32),
            toastLabel.leadingAnchor.constraint(greaterThanOrEqualTo: g.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(lessThanOrEqualTo: g.trailingAnchor, constant: -16),
        ])
    }

    func update(
        vcDisplay: String?,
        vcFull: String?,
        introspectedDisplay: String?,
        introspectedFull: String?,
        routeName: String?,
        configuration: Configuration
    ) {
        applyVerticalPositionIfNeeded(configuration.verticalPosition)

        vcFullName = vcFull
        introspectedFullName = introspectedFull
        routeFullName = routeName

        if configuration.viewController.enabled, let name = vcDisplay, !name.isEmpty {
            vcLabel.apply(text: name, style: configuration.viewController)
            vcLabel.isHidden = false
        } else {
            vcLabel.isHidden = true
        }

        // introspected 라벨은 vc 라벨과 다른 의미있는 이름을 얻었을 때만 노출
        if configuration.viewController.enabled,
           let name = introspectedDisplay,
           !name.isEmpty,
           name != vcDisplay {
            introspectedLabel.apply(text: name, style: configuration.viewController)
            introspectedLabel.isHidden = false
        } else {
            introspectedLabel.isHidden = true
        }

        if configuration.route.enabled, let name = routeName, !name.isEmpty {
            routeLabel.apply(text: name, style: configuration.route)
            routeLabel.isHidden = false
        } else {
            routeLabel.isHidden = true
        }
    }

    /// 윈도우 좌표의 탭 위치 — 라벨 영역 안이면 해당 풀네임을 토스트로 표시
    func handlePotentialLabelTap(at pointInWindow: CGPoint) {
        let pointInView = view.convert(pointInWindow, from: nil)
        if !vcLabel.isHidden, let name = vcFullName, vcLabel.frame.contains(pointInView) {
            showToast(name)
            return
        }
        if !introspectedLabel.isHidden, let name = introspectedFullName, introspectedLabel.frame.contains(pointInView) {
            showToast(name)
            return
        }
        if !routeLabel.isHidden, let name = routeFullName, routeLabel.frame.contains(pointInView) {
            showToast(name)
        }
    }

    private func showToast(_ text: String) {
        toastDismissWorkItem?.cancel()

        toastLabel.text = text

        UIView.animate(withDuration: 0.18) {
            self.toastLabel.alpha = 1
        }

        let dismiss = DispatchWorkItem { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.toastLabel.alpha = 0
            }
        }
        toastDismissWorkItem = dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: dismiss)
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
            c.append(leftLabelStack.topAnchor.constraint(equalTo: g.topAnchor, constant: 4))
            c.append(routeLabel.topAnchor.constraint(equalTo: g.topAnchor, constant: 4))
        case .bottom:
            c.append(leftLabelStack.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -4))
            c.append(routeLabel.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -4))
        }

        NSLayoutConstraint.activate(c)
        verticalConstraints = c
    }
}

@MainActor
private final class PassthroughView: UIView {
    /// 모든 영역 미터치 — 오버레이 윈도우의 hitTest와 함께 완전 통과
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

@MainActor
private final class ToastLabel: UILabel {

    private let contentInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    init() {
        super.init(frame: .zero)
        textColor = .white
        backgroundColor = UIColor.black.withAlphaComponent(0.85)
        font = .systemFont(ofSize: 13, weight: .medium)
        textAlignment = .center
        numberOfLines = 0
        layer.cornerRadius = 8
        clipsToBounds = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

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
