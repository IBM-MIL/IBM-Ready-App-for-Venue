/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit


/**
*  General utilities
*/
class Utils: NSObject {
    
    /**
    Gets a view controller from a stroyboard
    
    :param: vcName         Name of the view controller
    :param: storyboardName Name of the storyboard
    
    :returns: The view controller
    */
    class func vcWithNameFromStoryboardWithName(vcName : String, storyboardName : String) -> UIViewController?{
        let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle.mainBundle())
        let viewController = storyboard.instantiateViewControllerWithIdentifier(vcName)
        return viewController
    }
    
    /// Returns the size of a deal cell based on the width of the collectionview so that two deals take up the width of the screen with the correct ratio
    ///
    /// - parameter collectionView: The collectionview
    /// - parameter horizontalPadding: left and right side combined spacing on collectionview cells
    /// - parameter cellRatio: ratio of cell, width to height
    /// - returns: CGSize representation of the cell size
    class func sizeOfCellForCollectionView(collectionView: UICollectionView, horizontalPadding: CGFloat, cellRatio: CGFloat) -> CGSize {
        let collectionWidth = collectionView.frame.size.width - horizontalPadding
        let width = collectionWidth/2
        let height = width/cellRatio
        return CGSizeMake(width, height)
    }
    
    /// Method to combine large and small sized text into one string. Change font sizes as needed
    ///
    /// - parameter bigPart: String to increase in size
    /// - parameter smallPart: String to decrease in size
    /// - returns: NSMutableAttributedString with the 2 combined strings
    class func bigSmallLabelTransform(bigPart: String, smallPart: String) -> NSMutableAttributedString {
        
        let bigpartLength = bigPart.characters.count
        let smallpartLength = smallPart.characters.count
        let mutableString = NSMutableAttributedString(string: "\(bigPart)\(smallPart)", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(30)])
        mutableString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(18), range: NSRange(location: bigpartLength, length: smallpartLength))
        return mutableString
        
    }
    
}
