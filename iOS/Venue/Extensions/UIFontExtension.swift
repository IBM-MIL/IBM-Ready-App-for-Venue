/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

extension UIFont {
    
    /**
    Prints all the font names for the app to the console. This is helpful to find out if the font you added is in the project and to find the string needed to initialize a font with.
    */
    class func printAllFontNames(){
        for family in UIFont.familyNames(){
            print("\(family)")
            for font in UIFont.fontNamesForFamilyName((family)){
                print("\t\(font)")
            }
        }
    }
    
    class func latoBlack(size: CGFloat) -> UIFont{return UIFont(name: "Lato-Black", size: size)!}
    class func latoBold(size: CGFloat) -> UIFont{return UIFont(name: "Lato-Bold", size: size)!}
    class func latoRegular(size: CGFloat) -> UIFont{return UIFont(name: "Lato-Regular", size: size)!}
    class func latoLight(size: CGFloat) -> UIFont{return UIFont(name: "Lato-Light", size: size)!}
}
