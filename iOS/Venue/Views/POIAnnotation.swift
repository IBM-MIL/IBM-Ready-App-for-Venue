/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/


import UIKit

/// Subclass of VenueMapAnnotation. Represents a Point of Interest on the map.
class POIAnnotation: VenueMapAnnotation {

    var poiObject: POI!
    private var referencePoint = CGPoint()
    private let scale: CGFloat = 0.7
    
    init(poi: POI, location: CGPoint, zoomScale: CGFloat) {
        self.poiObject = poi
        let firstType = poiObject.types.first!
        let backgroundImage = UIImage(named: firstType.pin_image_name)!
        let width = backgroundImage.size.width * scale
        let height = backgroundImage.size.height * scale
        
        // Setup the frame of the button. The bottom middle point of the annotation is the reference point
        referencePoint = location
        let x = self.referencePoint.x * zoomScale - (width / 2)
        let y = self.referencePoint.y  * zoomScale - (height)
        
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        self.setBackgroundImage(backgroundImage, forState: UIControlState.Normal)
        self.accessibilityIdentifier = self.poiObject.name
        self.accessibilityHint = firstType.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateLocation(mapZoomScale: CGFloat) {
        // This point needs to move to keep the bottom middle of the image in the same location. The other annotation
        // types moves to keep the center of the annotation in the same relative spot
        self.frame.origin.x = (self.referencePoint.x * mapZoomScale) - (self.frame.size.width / 2)
        self.frame.origin.y = (self.referencePoint.y * mapZoomScale) - (self.frame.size.height)
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
        let y = (self.referencePoint.y * zoomScale) - (height)
        return CGPoint(x: x, y: y)
    }
    
    /**
    When this annotation is selected, change the frame of the annotation accordingly.
    
    - parameter mapZoomScale: The zoom scale of the containing scroll view
    */
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
    Applies the given filters to this annotation
    
    - parameter filter:         The filter array of the different types
    */
    func applyFilter(filter: [Type]) {
        
        // Filter based on type
        for poiType in poiObject.types {
            for type in filter {
                if poiType.id == type.id {
                    if type.shouldDisplay {
                        self.hidden = false
                        return
                    } else {
                        self.hidden = true
                    }
                }
            }
        }
    }
    
    /**
    Filter based on the minimum height requirement
    
    - parameter heightFilter:   The int value for minimum height
    
    - returns: Bool indicating if this annotation is now hidden or not
    */
    func filterHeight(heightFilter: Int) -> Bool {
        if (poiObject.height_requirement > 0) && (poiObject.height_requirement > heightFilter) {
            self.hidden = true
        } else {
            self.hidden = false
        }
        return self.hidden
    }
    
    /**
    Filter based on maximum wait time
    
    - parameter waitTime: The int value for maximum wait
    
    - returns: Bool indicating if this annotation is now hidden or not
    */
    func filterWaitTime(waitTime: Int) -> Bool {
        if (poiObject.wait_time > 0) && (poiObject.wait_time > waitTime) {
            self.hidden = true
        } else {
            self.hidden = false
        }
        return self.hidden
    }
}
