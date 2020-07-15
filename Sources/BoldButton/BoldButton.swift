import UIKit

public typealias BoldButtonAction = ((BoldButton) -> Void)

@IBDesignable
public class BoldButton: UIControl, Highlatable {
    
    // MARK: Public properties
    
    /// Action performed on button press.
    public var pressHandler: BoldButtonAction?
    
    /// Text displayed in button.
    @IBInspectable public var text: String? {
        didSet {
            textLabel.text = text
            textLabel.isHidden = text == nil || text?.isEmpty == true
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    /// Image displayed left to the text displayed in the button.
    @IBInspectable public var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.isHidden = image == nil
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    @IBInspectable public var isLoading = false {
        didSet {
            stack.isHidden = isLoading
            isLoading ? indicator.startAnimating() : indicator.stopAnimating()
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    /// Dimming style applied to button when it detects press.
    public dynamic var dimmingStyle: DimmingStyle {
        get {
            return DimmingStyle(adapter: dimmingStyleAdapter, ratio: dimmingStyleAdapterRatio)
        } set {
            dimmingStyleAdapter = newValue.components.adapter
            dimmingStyleAdapterRatio = newValue.components.ratio
        }
    }
    
    // MARK: UIAppearance-compatible properties
    @IBInspectable public dynamic var showsShadowUnderContent = false {
        didSet {
            /// Shadow is added/removed in `layoutSubviews()` methods
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #else
                layoutIfNeeded()
            #endif
        }
    }
    
    @IBInspectable public dynamic var dimmingStyleAdapter: DimmingStyleAdapter = .alpha
    
    @IBInspectable public dynamic var dimmingStyleAdapterRatio: CGFloat = 0.5
    
    /// Property declaring if tint color in selected state should be light, or dark.
    @IBInspectable public dynamic var style: Style = .light {
        didSet {
            updateColors()
        }
    }
    
    // MARK: Private properties
    @objc private dynamic var backgroundView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    @objc private dynamic var indicator: UIActivityIndicatorView = {
        let i: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            i = UIActivityIndicatorView(style: .medium)
        } else {
            i = UIActivityIndicatorView(style: .gray)
        }
        i.hidesWhenStopped = true
        i.translatesAutoresizingMaskIntoConstraints = false
        i.isUserInteractionEnabled = false
        return i
    }()
    
    @objc private dynamic var textLabel: UILabel = {
        let l = UILabel()
        l.text = "Button"
        l.isHidden = true
        l.textAlignment = .center
        l.isUserInteractionEnabled = false
        l.setContentHuggingPriority(.required, for: .vertical)
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()
    
    @objc private dynamic var imageView: UIImageView = {
        let i = UIImageView()
        i.isHidden = true
        i.contentMode = .scaleAspectFit
        i.isUserInteractionEnabled = false
        return i
    }()
    
    private lazy var stack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [imageView, textLabel])
        s.axis = .horizontal
        s.spacing = 10
        s.alignment = .center
        s.distribution = .equalCentering
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isUserInteractionEnabled = false
        return s
    }()
    
    // MARK: Initizalization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

// MARK: Setup methods
private extension BoldButton {
    func commonInit() {
        clipsToBounds = true
        if backgroundColor == nil {
            backgroundColor = .buttonBackground
        }
        addTargets()
        setupViews()
    }
    
    func setupViews() {
        addSubview(backgroundView)
        addSubview(stack)
        addSubview(indicator)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 6),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            imageView.heightAnchor.constraint(equalTo: textLabel.heightAnchor, multiplier: 1),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
    }
    
    func addTargets() {
        addTarget(self, action: #selector(didTouchDownInside(_:)), for: [.touchDown, .touchDownRepeat])
        addTarget(self, action: #selector(didTouchUpInside), for: [.touchUpInside])
        addTarget(self, action: #selector(didDragOutside), for: [.touchDragExit, .touchCancel])
        addTarget(self, action: #selector(didDragInside), for: [.touchDragEnter])
    }
    
    func updateColors() {
        backgroundView.backgroundColor = isSelected ? tintColor : backgroundColor
        
        var tint = isSelected ? style.color : tintColor
        if let background = backgroundView.backgroundColor, tint?.isEqualToColor(color: background, withTolerance: 0.3) == true {
            tint = style.other.color
        }
        
        imageView.tintColor = tint
        textLabel.textColor = tint
    }
}

// MARK: Overriden methods
extension BoldButton {
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateColors()
        layer.cornerRadius = 10
        if showsShadowUnderContent {
            textLabel.dropShadow()
            imageView.dropShadow()
        } else {
            textLabel.removeShadow()
            imageView.removeShadow()
        }
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        updateColors()
    }
}

// MARK: Overriden properties
extension BoldButton {
    public override var isHighlighted: Bool {
        didSet {
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    public override var isSelected: Bool {
           didSet {
            updateColors()
               #if TARGET_INTERFACE_BUILDER
                   setNeedsLayout()
               #endif
           }
       }
    
    public override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.3
            isUserInteractionEnabled = isEnabled
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        let padding: CGFloat = 30
        return CGSize(width: (textLabel.intrinsicContentSize.width + imageView.intrinsicContentSize.width) + (2 * padding), height: 48)
    }
    
    /// Color applied to image and text. Overrides `color` value.
    public override var tintColor: UIColor! {
        didSet {
            updateColors()
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            updateColors()
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    /// Content mode applied to image.
    public override var contentMode: UIView.ContentMode {
        didSet {
            imageView.contentMode = contentMode
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
}

// MARK: Interactions
private extension BoldButton {
    @objc func didTouchDownInside(_ sender: Any) {
        highlight()
    }
    
    @objc func didTouchUpInside() {
        unhighlight()
        pressHandler?(self)
    }
    
    @objc func didDragOutside() {
        unhighlight()
    }
    
    @objc func didDragInside() {
        highlight()
    }
}

public extension BoldButton {
    @objc enum Style: Int {
        case light
        case dark
    }
    
    var dimmedView: UIView {
        return self
    }
}

extension BoldButton.Style {
    var other: BoldButton.Style {
        switch self {
        case .light:
            return .dark
        case .dark:
            return .light
        }
    }
    
    var color: UIColor {
        switch self {
        case .light:
            return .white
        case .dark:
            return .darkGray
        }
    }
}
