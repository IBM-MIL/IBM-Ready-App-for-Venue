/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// View model to handle displaying a map of the user in the Person Details page
class PersonDetailsViewModel: NSObject {
    
    var person: User!
    private var pinOffset: (CGFloat, CGFloat) = (0.0, 0.0)
    
    init(person: User) {
        self.person = person
        super.init()
    }

    
    func croppedMapImage(width: CGFloat, height: CGFloat) -> UIImage? {
        let image = UIImage(named: "map")!
        let rectWidth = width * 4.0
        let rectHeight = height * 4.0
        var pinOrigin = CGPoint(x: person.currentLocationX, y: person.currentLocationY)
        
        let rectMaxPointX = CGFloat(person.currentLocationX) * image.scale + (rectWidth / 2)
        let rectMinPointX = CGFloat(person.currentLocationX) * image.scale - (rectWidth / 2)
        let imageWidth = image.size.width * image.scale
        
        if  rectMaxPointX > imageWidth {
            let offset = rectMaxPointX - imageWidth
            pinOrigin.x -= offset
            pinOffset.0 = offset / image.scale
        } else if rectMinPointX < 0 {
            let offset = rectMinPointX
            pinOrigin.x -= offset
            pinOffset.0 = offset / image.scale
        }
        
        let rectMaxPointY = CGFloat(person.currentLocationY) * image.scale + (rectHeight / 2)
        let rectMinPointY = CGFloat(person.currentLocationY) * image.scale - (rectHeight / 2)
        let imageHeight = (image.size.height * image.scale)
        
        if rectMaxPointY > imageHeight {
            let offset = rectMaxPointY - imageHeight
            pinOrigin.y -= offset
            pinOffset.1 = offset / image.scale
        } else if rectMinPointY < 0 {
            let offset = rectMinPointY
            pinOrigin.y -= offset
            pinOffset.1 = offset / image.scale
        }
        
        return image.cropImageAroundPoint(pinOrigin, size: CGSize(width: rectWidth, height: rectHeight))
    }
    
    func applyPinOffset(currentOrigin: CGPoint) -> CGPoint {
        return CGPoint(x: currentOrigin.x + pinOffset.0, y: currentOrigin.y + pinOffset.1)
    }
}
