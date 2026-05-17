#if DEBUG
import UIKit

@MainActor
final class OverlayViewController: UIViewController {

    // 라벨들은 테스트에서 .text / .isHidden 확인 위해 internal — 외부 모듈에 노출되지는 않음
    let vcLabel = PaddedLabel()
    let childLabel = PaddedLabel()
    let introspectedLabel = PaddedLabel()
    private let leftLabelStack = UIStackView()
    let routeLabel = PaddedLabel()
    let toastLabel = ToastLabel()

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

        for label in [vcLabel, childLabel, introspectedLabel, routeLabel] {
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }

        // 좌측: vc / child / introspected 세 라벨을 stack 에 담아 hidden 시 자동 collapse
        leftLabelStack.axis = .vertical
        leftLabelStack.alignment = .leading
        leftLabelStack.spacing = 2
        leftLabelStack.translatesAutoresizingMaskIntoConstraints = false
        leftLabelStack.addArrangedSubview(vcLabel)
        leftLabelStack.addArrangedSubview(childLabel)
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
        childDisplay: String?,
        introspectedDisplay: String?,
        routeName: String?,
        configuration: Configuration
    ) {
        applyVerticalPositionIfNeeded(configuration.verticalPosition)

        if configuration.viewController.enabled, let name = vcDisplay, !name.isEmpty {
            vcLabel.apply(text: name, style: configuration.viewController)
            vcLabel.isHidden = false
        } else {
            vcLabel.isHidden = true
        }

        // child 라벨 — 부모 VC 안에 떠 있는 사용자 코드 child VC. vc 와 같으면 중복이므로 숨김
        if configuration.viewController.enabled,
           let name = childDisplay,
           !name.isEmpty,
           name != vcDisplay {
            childLabel.apply(text: name, style: configuration.viewController)
            childLabel.isHidden = false
        } else {
            childLabel.isHidden = true
        }

        // introspected 라벨 — SwiftUI 내부 사용자 View 타입. vc / child 라벨과 같으면 중복이므로 숨김
        if configuration.viewController.enabled,
           let name = introspectedDisplay,
           !name.isEmpty,
           name != vcDisplay,
           name != childDisplay {
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

    /// 윈도우 좌표의 탭 위치 — 라벨 영역 안이면 그 라벨에 표시된 이름을 토스트로 그대로 노출
    func handlePotentialLabelTap(at pointInWindow: CGPoint) {
        for label in [vcLabel, childLabel, introspectedLabel, routeLabel] {
            if !label.isHidden,
               let text = label.text,
               !text.isEmpty,
               contains(label: label, pointInWindow: pointInWindow) {
                showToast(text)
                return
            }
        }
    }

    /// 라벨이 중첩 superview (UIStackView 등) 안에 있어도 작동하도록 라벨 자신의 좌표계로
    /// 변환해 bounds 검사 — `label.frame` 은 부모 좌표계라 view 좌표 비교 시 빗나감
    private func contains(label: UIView, pointInWindow: CGPoint) -> Bool {
        let pointInLabel = label.convert(pointInWindow, from: nil)
        return label.bounds.contains(pointInLabel)
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
final class PaddedLabel: UILabel {

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
final class ToastLabel: UILabel {

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
