/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/


import UIKit

/// Subclass of VenueMapAnnotation. Represents an annotation for the user's current location.
class MyLocationAnnotation: VenueMapAnnotation {

    var userObject: User!
    private let imageName = "your_location"
    private var referencePoint = CGPoint()
    
    init(user: User, location: CGPoint) {
        self.userObject = user
        let backgroundImage = UIImage(named: imageName)!
        
        // Setup the frame for the button
        referencePoint = location
        let x = self.referencePoint.x - (backgroundImage.size.width / 2)
        let y = self.referencePoint.y - (backgroundImage.size.height / 2)

        super.init(frame: CGRect(x: x, y: y, width: backgroundImage.size.width, height: backgroundImage.size.height))
        
        self.setBackgroundImage(backgroundImage, forState: UIControlState.Normal)
        self.accessibilityIdentifier = self.userObject.name
        self.accessibilityHint = "Current User"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateLocation(mapZoomScale: CGFloat) {
        self.center.x = (self.referencePoint.x * mapZoomScale)
        self.center.y = (self.referencePoint.y * mapZoomScale)
    }
    
    override func updateReferencePoint(newReferencePoint: CGPoint, mapZoomScale: CGFloat) {
        self.referencePoint = newReferencePoint
        self.updateLocation(mapZoomScale)
    }
    
    override func annotationSelected(mapZoomScale: CGFloat) {
        // Nothing happens for this type of annotation
    }
    
    override func getReferencePoint() -> CGPoint {
        return self.referencePoint
    }
}
