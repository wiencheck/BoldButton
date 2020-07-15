import UIKit

extension UIView {
    @objc func dropShadow(color: UIColor = .black, opacity: Float = 0.7, offSet: CGSize = CGSize(width: 0, height: 1), radius: CGFloat = 3, scale: Bool = true) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = offSet  //Here you control x and y
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0 //Here your control your blur
        layer.masksToBounds =  false
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    @objc func removeShadow() {
        layer.shadowColor = nil
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.masksToBounds =  false
    }
}
