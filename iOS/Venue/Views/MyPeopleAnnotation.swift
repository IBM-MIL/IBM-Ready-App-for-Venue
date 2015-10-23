/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/


import UIKit

/// Subclass of VenueMapAnnotation. Represents a Person on the map
class MyPeopleAnnotation: VenueMapAnnotation {

    var userObject: User!
    private let imageName = "person"
    private var referencePoint = CGPoint()
    private let scale: CGFloat = 0.7
    
    init(user: User, location: CGPoint, zoomScale: CGFloat) {
        self.userObject = user
        let backgroundImage = UIImage(named: imageName)!
        let width = backgroundImage.size.width * scale
        let height = backgroundImage.size.height * scale
        
        // Setup the frame of the button
        referencePoint = location
        let x = (self.referencePoint.x * zoomScale) - (width / 2)
        let y = (self.referencePoint.y * zoomScale) - (height / 2)

        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        
        // Set background image and initials of person
        self.setBackgroundImage(backgroundImage, forState: UIControlState.Normal)
        self.setTitle(self.userObject.initials, forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont.latoBold(12.0)
        self.accessibilityLabel = userObject.name
        self.accessibilityHint = "People"
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
    
    override func getReferencePoint() -> CGPoint {
        return self.referencePoint
    }
    
    private func calculateOriginPoint(width: CGFloat, height: CGFloat, zoomScale: CGFloat) -> CGPoint {
        let x = (self.referencePoint.x * zoomScale) - (width / 2)
        let y = (self.referencePoint.y * zoomScale) - (height / 2)
        return CGPoint(x: x, y: y)
    }
    
    override func annotationSelected(mapZoomScale: CGFloat) {
        currentlySelected = !currentlySelected
        let backgroundImage = self.backgroundImageForState(.Normal)!
        let width : CGFloat!
        let height : CGFloat!
        if currentlySelected {
            width = backgroundImage.size.width
            height = backgroundImage.size.height
        } else {
            width = backgroundImage.size.width * scale
            height = backgroundImage.size.height * scale
        }
        
        let newOrigin = self.calculateOriginPoint(width, height: height, zoomScale: mapZoomScale)
        
        UIView.animateWithDuration(0.3, animations: { Void in
            self.frame = CGRect(x: newOrigin.x, y: newOrigin.y, width: width, height: height)
        })
    }
    
    /**
    Applies the filter. Only shown if the People type is selected.
    
    - parameter filter: The array of filters
    */
    func appyFilter(filter: [Type]) {
        for type in filter {
            if type.name == "People" {
                if type.shouldDisplay {
                    self.hidden = false
                } else {
                    self.hidden = true
                }
                return
            }
        }
    }
}
