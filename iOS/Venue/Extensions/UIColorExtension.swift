/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/
import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    class func venueRed(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 255.0/255.0, green: 23.0/255.0, blue: 68.0/255.0, alpha: alpha)}
    class func venueBabyBlue(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 231.0/255.0, green: 245.0/255.0, blue: 255.0/255.0, alpha: alpha)}
    class func venueLightBlue(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 124.0/255.0, green: 199.0/255.0, blue: 255.0/255.0, alpha: alpha)}
    class func venueNavyBlue(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 38.0/255.0, green: 74.0/255.0, blue: 96.0/255.0, alpha: alpha)}
    class func venueDarkGray(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: alpha)}
    
    class func venueLightGreen(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 0.0/255.0, green: 200.0/255.0, blue: 83.0/255.0, alpha: alpha)}
    class func venueLightOrange(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 255.0/255.0, green: 171.0/255.0, blue: 0.0/255.0, alpha: alpha)}
    
    class func venueSelectionBlue(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 51.0/255.0, green: 153.0/255.0, blue: 255.0/255.0, alpha: alpha)}
}