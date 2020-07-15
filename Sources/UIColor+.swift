import UIKit

extension UIColor {
    func isEqualToColor(color: UIColor, withTolerance tolerance: CGFloat = 0.0) -> Bool {
        
        var r1 : CGFloat = 0
        var g1 : CGFloat = 0
        var b1 : CGFloat = 0
        var a1 : CGFloat = 0
        var r2 : CGFloat = 0
        var g2 : CGFloat = 0
        var b2 : CGFloat = 0
        var a2 : CGFloat = 0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return
            abs(r1 - r2) <= tolerance &&
                abs(g1 - g2) <= tolerance &&
                abs(b1 - b2) <= tolerance &&
                abs(a1 - a2) <= tolerance
    }
    
    func isDistinct(from color: UIColor) -> Bool {
        return isEqualToColor(color: color, withTolerance: 0.5) == false
    }
    
    class var buttonBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 0.09, green: 0.105, blue: 0.117, alpha: 1)
                }
                return .systemGroupedBackground
            }
        } else {
            return .groupTableViewBackground
        }
    }
}
