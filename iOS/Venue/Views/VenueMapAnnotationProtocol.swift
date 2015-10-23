/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/


import UIKit

/// This is a supercalls for all annotation types
class VenueMapAnnotation: UIButton, VenueMapAnnotationProtocol {
    var currentlySelected = false
    
    func updateLocation(mapZoomScale: CGFloat) {
        
    }
    
    func updateReferencePoint(newReferencePoint: CGPoint, mapZoomScale: CGFloat) {
        
    }
    
    func getReferencePoint() -> CGPoint {
        return CGPoint()
    }
    
    func annotationSelected(mapZoomScale: CGFloat) {
        
    }
}

/**
*  This protocol defines the functions that all annotations for the map page need to implement
*/
protocol VenueMapAnnotationProtocol {
    /**
    This function must be created by conforming classes to determine how the annotation
    should move on the map when the map is zoomed
    
    :param: mapZoomScale The zoom scale of the map
    */
    func updateLocation(mapZoomScale: CGFloat)
    
    /**
    This function must be created by conforming classes to determine what happens when the
    reference point for the annotation is changed.
    
    :param: newReferencePoint The new reference point for the annotation
    :param: mapZoomScale    The zoom scale of the scroll view
    */
    func updateReferencePoint(newReferencePoint: CGPoint, mapZoomScale: CGFloat)
    
    /**
    This function must be created by conforming classes to return the correct reference point
    
    :returns: The reference point of the annotation
    */
    func getReferencePoint() -> CGPoint
    
    /**
    This function should determine what should happen when this annotation is selected
    
    - parameter mapZoomScale: The zoom scale of the containing scroll view
    */
    func annotationSelected(mapZoomScale: CGFloat)
}
