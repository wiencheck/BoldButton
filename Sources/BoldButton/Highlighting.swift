//
//  File.swift
//  
//
//  Created by Adam Wienconek on 12/05/2021.
//

import UIKit

/// Protocol which makes it easy to add custom appearance for views during interactions.
protocol Highlighting: UIView {
    /// Style of animations used during highlighting.
    var dimmingStyle: DimmingStyle { get }
    
    /// Optional view on which animations will be performed, defaults to `self`.
    /// For example `UITableViewCell` could return its `imageView` here.
    var dimmedView: UIView { get }
}

extension Highlighting {
    var dimmingStyle: DimmingStyle {
        return .contentAlpha(0.5)
    }
    
    var dimmedView: UIView {
        return self
    }
    
    /// Begin custom highlighting animations based on `dimmingStyle` value.
    func highlight(animated: Bool = true) {
        let duration: TimeInterval = animated ? 0.1 : 0
        let dimmingView: DimmingView
        switch dimmingStyle {
        case .alpha(let value):
            UIView.animate(withDuration: duration) {
                self.dimmedView.alpha = value
            }
            return
        case .contentAlpha(let value):
            UIView.animate(withDuration: duration) {
                for view in self.dimmedView.subviews {
                    if view.bounds == self.dimmedView.bounds {
                        /* Skip subviews which are pinned to superview's bounds as they're probably background views */
                        continue
                    }
                    view.alpha = value
                }
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
    
    /// Finish animations and return to initial state.
    func unhighlight(animated: Bool = true) {
        let duration: TimeInterval = animated ? 0.1 : 0
        switch dimmingStyle {
        case .alpha(_):
            UIView.animate(withDuration: duration) {
                self.dimmedView.alpha = 1
            }
        case .contentAlpha(_):
            UIView.animate(withDuration: duration) {
                for view in self.dimmedView.subviews {
                    if view.bounds == self.dimmedView.bounds {
                        /* Skip subviews which are pinned to superview's bounds as they're probably background views */
                        continue
                    }
                    view.alpha = 1
                }
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

/// Style used for configuring view's animation upon highlighting.
public enum DimmingStyle {
    /// Highlighted view changes its opacity to given value.
    case alpha(CGFloat)
    
    /// Highlighted view changes opacity of its subviews.
    case contentAlpha(CGFloat)
    
    /// Highlighted view places a light overlay on top with given opacity.
    case lighten(CGFloat)
    
    /// Highlighted view places a dark overlay on top with given opacity.
    case darken(CGFloat)
    
    /// Highlighted view changes its size by given multiplier.
    case scale(CGFloat)
    
    /// Highlighted view places an overlay colored with a its own `tintColor` on top with given opacity.
    case tint(CGFloat)
}

extension DimmingStyle {
    init(adapter: DimmingStyleAdapter, ratio: CGFloat) {
        switch adapter {
        case .alpha: self = .alpha(ratio)
        case .contentAlpha: self = .contentAlpha(ratio)
        case .lighten: self = .lighten(ratio)
        case .darken: self = .darken(ratio)
        case .scale: self = .scale(ratio)
        case .tint: self = .tint(ratio)
        }
    }
    
    var components: (adapter: DimmingStyleAdapter, ratio: CGFloat) {
        switch self {
        case .alpha(let ratio): return (adapter: .alpha, ratio: ratio)
        case .contentAlpha(let ratio): return (adapter: .contentAlpha, ratio: ratio)
        case .lighten(let ratio): return (adapter: .lighten, ratio: ratio)
        case .darken(let ratio): return (adapter: .darken, ratio: ratio)
        case .scale(let ratio): return (adapter: .scale, ratio: ratio)
        case .tint(let ratio): return (adapter: .tint, ratio: ratio)
        }
    }
}

/// Helper enum used to help expose `DimmingStyle` to `UIAppearance` mechanism.
@objc public enum DimmingStyleAdapter: Int {
    case alpha
    case contentAlpha
    case lighten
    case darken
    case scale
    case tint
}

/// Overlay view used for animations.
fileprivate class DimmingView: UIView {
    init(color: UIColor) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
