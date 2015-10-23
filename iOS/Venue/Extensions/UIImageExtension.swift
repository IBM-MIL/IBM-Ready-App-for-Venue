/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/
import UIKit

extension UIImage {

    /**
    Crops the image around the given point and with the given size
    
    - parameter point: The center point of the image to crop around
    - parameter size:  The size of the image to crop
    
    - returns: Returns the cropped image
    */
    func cropImageAroundPoint(point: CGPoint, size: CGSize) -> UIImage {
        
        // Setup x coordinate, and make sure it doesnt start < 0 or that the width doesnt extend past boundary
        let rectOriginX = (CGFloat(point.x) * self.scale) - (size.width / 2)
        let rectOriginY = (CGFloat(point.y) * self.scale) - (size.height / 2)
        
        
        // Crop image and return
        let rect = CGRectMake(rectOriginX, rectOriginY, size.width, size.height)
        let newImageRef = CGImageCreateWithImageInRect(self.CGImage, rect)!
        return UIImage(CGImage: newImageRef)
    }

}