/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// Custom label that can easily change colors based on wait time
class VenueWaitLabel: UILabel {
    
    /**
    Determins color value based on wait time
    
    - parameter waitTime: wait time for a particular POI
    
    - returns: a `UIColor` based on the wait time
    */
    func colorForTime(waitTime: Int) -> UIColor {
        if waitTime < 30 {
            return UIColor.venueLightGreen()
        } else if waitTime >= 30 && waitTime < 60 {
            return UIColor.venueLightOrange()
        } else {
            return UIColor.venueRed()
        }
    }

    /**
    Method to update textColor based on short or long wait times
    
    - parameter waitTime: wait time for a particular POI
    */
    func updateTextColor(waitTime: Int) {
        self.textColor = colorForTime(waitTime)
    }

}
