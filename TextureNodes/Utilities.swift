import UIKit

extension UIColor {
  
  static let primaryColor: UIColor = UIColor.red
  
}

extension NSAttributedString {
  
  static func attributedString(string: String?, fontSize size: CGFloat, color: UIColor?) -> NSAttributedString? {
    guard let string = string else { return nil }
    
    let attributes = [
      NSAttributedString.Key.foregroundColor: color ?? UIColor.black,
      NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: size)
    ]
    
    return NSMutableAttributedString(string: string, attributes: attributes)
  }
  
}

extension UIImage {
  
  class func draw(size: CGSize, fillColor: UIColor, shapeClosure: () -> UIBezierPath) -> UIImage {
    UIGraphicsBeginImageContext(size)
    
    let path = shapeClosure()
    path.addClip()
    
    fillColor.setFill()
    path.fill()
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
  }
  
}
