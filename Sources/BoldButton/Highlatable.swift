import UIKit

public protocol Highlatable: UIView {
    var dimmingStyle: DimmingStyle { get }
    var dimmedView: UIView { get }
}

extension Highlatable {
    var dimmingStyle: DimmingStyle {
        return .darken(0.5)
    }
    
    var dimmedView: UIView {
        return self
    }
    
    func highlight(animated: Bool = true) {
        let duration: TimeInterval = animated ? 0.1 : 0
        let dimmingView: DimmingView
        switch dimmingStyle {
        case .alpha(let value):
            UIView.animate(withDuration: duration) {
                self.dimmedView.alpha = value
            }
            return
        case .scale(let scale):
            UIView.animate(withDuration: duration) {
                self.dimmedView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            return
        case .lighten(let alpha):
            dimmingView = DimmingView(color: UIColor.white.withAlphaComponent(alpha))
            
        case .darken(let alpha):
            dimmingView = DimmingView(color: UIColor.black.withAlphaComponent(alpha))
            
        case .tint(let alpha):
            dimmingView = DimmingView(color: tintColor.withAlphaComponent(alpha))
        }
        
        dimmingView.alpha = 0
        insertSubview(dimmingView, aboveSubview: dimmedView)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: dimmedView.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: dimmedView.leadingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: dimmedView.bottomAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: dimmedView.trailingAnchor)
        ])
        
        UIView.animate(withDuration: duration) {
            dimmingView.alpha = 1
        }
    }
    
    func unhighlight(animated: Bool = true) {
        let duration: TimeInterval = animated ? 0.1 : 0
        switch dimmingStyle {
        case .alpha(_):
            UIView.animate(withDuration: duration) {
                self.dimmedView.alpha = 1
            }
        case .scale(_):
            UIView.animate(withDuration: duration) {
                self.dimmedView.transform = .identity
            }
        case .lighten(_), .darken(_), .tint(_):
            guard let dimmingView = subviews.first (where: { $0 is DimmingView }) as? DimmingView else {
                return
            }
            UIView.animate(withDuration: duration, animations: {
                dimmingView.alpha = 0
            }) { _ in
                dimmingView.removeFromSuperview()
            }
        }
    }
}

public enum DimmingStyle {
    case alpha(CGFloat)
    case lighten(CGFloat)
    case darken(CGFloat)
    case scale(CGFloat)
    case tint(CGFloat)
}

fileprivate class DimmingView: UIView {
    init(color: UIColor = UIColor.black.withAlphaComponent(0.5)) {
        super.init(frame: .zero)
        backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
