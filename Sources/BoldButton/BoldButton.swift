import UIKit

public typealias BoldButtonAction = ((BoldButton) -> Void)

@IBDesignable
public class BoldButton: UIView, Highlatable {
    
    // MARK: Public stuff
    
    /// Action performed on button press.
    public var pressHandler: BoldButtonAction?
    
    /// Dimming style applied to button when it detects press.
    public var dimmingStyle: DimmingStyle = .darken(0.3)
    
    /// Text displayed in button.
    @IBInspectable public var text: String? = "Button" {
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
    
    /// If `true`, button will be highlighted with `tintColor`
    @IBInspectable public var isHighlighted = false {
        didSet {
            updateColors()
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    /// Property declaring if tint color in selected state should be light, or dark.
    @IBInspectable public var style: Style = .light {
        didSet {
            updateColors()
        }
    }
        
    /// Value indicating whether button should be enabled.
    @IBInspectable public var isEnabled = true {
        didSet {
            alpha = isEnabled ? 1 : 0.3
            tap.isEnabled = isEnabled
            #if TARGET_INTERFACE_BUILDER
                setNeedsLayout()
            #endif
        }
    }
    
    // MARK: Private stuff
    
    @objc private dynamic var backgroundView: UIView = {
        let v = UIView()
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
        return s
    }()
    
    private lazy var tap: UIGestureRecognizer = {
        let t = UILongPressGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        t.minimumPressDuration = 0
        return t
    }()
    
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
    
    private var isHighlighting = false {
        didSet {
            isHighlighting ? highlight() : unhighlight()
        }
    }

    @objc private func handleGesture(_ sender: UIGestureRecognizer) {
        let point = sender.location(in: self)
        
        let transform = CGAffineTransform(scaleX: 1.2, y: 1.2).concatenating(CGAffineTransform(translationX: -10, y: -10))
        let expandedBounds = bounds.applying(transform)
        let isTouchInside = expandedBounds.contains(point)
        
        switch sender.state {
        case .began:
            isHighlighting = true
        case .ended:
            if isTouchInside {
                pressHandler?(self)
            }
            isHighlighting = false
        case .changed:
            if isHighlighting == isTouchInside {
                return
            }
            isHighlighting = isTouchInside
        default:
            isHighlighting = false
        }
    }
        
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateColors()
        layer.cornerRadius = 10
        textLabel.dropShadow()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = true
        if backgroundColor == nil {
            if #available(iOS 13.0, *) {
                backgroundColor = .systemGroupedBackground
            } else {
                backgroundColor = .groupTableViewBackground
            }
        }
        addGestureRecognizer(tap)
        
        setupViews()
    }
    
    private func setupViews() {
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
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        updateColors()
    }
    
    private func updateColors() {
        backgroundView.backgroundColor = isHighlighted ? tintColor : backgroundColor
        
        var tint = isHighlighted ? style.color : tintColor
        if let background = backgroundView.backgroundColor, tint?.isEqualToColor(color: background, withTolerance: 0.3) == true {
            tint = style.other.color
        }
        
        imageView.tintColor = tint
        textLabel.textColor = tint
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
