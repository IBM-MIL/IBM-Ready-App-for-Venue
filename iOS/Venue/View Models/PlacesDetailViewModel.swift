/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// This is the view model for the POI Detail screen
class PlacesDetailViewModel: NSObject {

    var poi: POI!
    let heightRequirementDetailId: Int = 10
    dynamic var favoriteImageName = "star"
    private var isFavorited = false
    private var pinOffset: (CGFloat, CGFloat) = (0.0, 0.0)
    
    required init(poi: POI) {
        super.init()
        
        self.poi = poi
        
        // Check if this item is favorited
        let currentUser = UserDataManager.sharedInstance.currentUser
        let filteredArray = currentUser.favorites.filter { $0.favoritedPOI.id == self.poi.id }
        if  !filteredArray.isEmpty {
            self.isFavorited = true
            self.favoriteImageName = "star_filled"
        }
    }
    
    /**
    Calculates the wait time text
    */
    func getWaitTimeText() -> String {
        let waitTime = poi.wait_time
        if waitTime < 0 {
            return ""
        } else if waitTime >= 0 && waitTime <= 60 {
            return "\(waitTime)"
        } else {
            return "60+"
        }
    }
    
    /**
    Determines the color based on the wait time
    */
    func getWaitTimeColor() -> UIColor {
        let waitTime = poi.wait_time
        if waitTime < 30 {
            return UIColor.venueLightGreen()
        } else if waitTime >= 30 && waitTime < 60 {
            return UIColor.venueLightOrange()
        } else {
            return UIColor.venueRed()
        }
    }
    
    /**
    This function creates a cropped image of the map with the POI at the center.
    
    - parameter width:  The width of the image view
    - parameter height: The height of the image view
    
    - returns: A cropped UIImage of the map
    */
    func croppedMapImage(width: CGFloat, height: CGFloat) -> UIImage? {
        let image = UIImage(named: "map")!
        let rectWidth = width * 4.0
        let rectHeight = height * 4.0
        var pinOrigin = CGPoint(x: self.poi.coordinateX, y: self.poi.coordinateY)
        
        let rectMaxPointX = CGFloat(poi.coordinateX) * image.scale + (rectWidth / 2)
        let rectMinPointX = CGFloat(poi.coordinateX) * image.scale - (rectWidth / 2)
        let imageWidth = image.size.width * image.scale
        
        // If the edge of the cropped image goes past the edge of the image, move it back
        if  rectMaxPointX > imageWidth {
            let offset = rectMaxPointX - imageWidth
            pinOrigin.x -= offset
            pinOffset.0 = offset / image.scale
        } else if rectMinPointX < 0 {
            let offset = rectMinPointX
            pinOrigin.x -= offset
            pinOffset.0 = offset / image.scale
        }
        
        let rectMaxPointY = CGFloat(poi.coordinateY) * image.scale + (rectHeight / 2)
        let rectMinPointY = CGFloat(poi.coordinateY) * image.scale - (rectHeight / 2)
        let imageHeight = (image.size.height * image.scale)
        
        // If the edge of the cropped image goes past the edge of the image, move it back
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
    
    // Move the origin of the pin based on any offsets applied when creating the cropped map image
    func applyPinOffset(currentOrigin: CGPoint) -> CGPoint {
        return CGPoint(x: currentOrigin.x + pinOffset.0, y: currentOrigin.y + pinOffset.1)
    }
    
    /**
    Sets up the detailed cell for the details about a POI
    
    - parameter cell:      The cell to setup
    - parameter indexPath: The index of the cell
    */
    func setupDetailCell(cell: POIDetailsTableViewCell, indexPath: NSIndexPath) {
        let details = poi.details
        if indexPath.row < details.count {
            let detail = details[indexPath.row]
            if detail.id != heightRequirementDetailId {
                cell.detailLabel.text = details[indexPath.row].message
            } else {
                let heightRequirement = poi.height_requirement
                if heightRequirement <= 0 {
                    cell.detailLabel.text = detail.message + NSLocalizedString(": None", comment: "")
                } else {
                    cell.detailLabel.text = detail.message + ": \(heightRequirement)\""
                }
            }
        }
    }
    
    /**
    Changes the favorited status of this poi
    */
    func favoritedIconSelected() {
        isFavorited = !isFavorited
        if isFavorited {
            self.favoriteImageName = "star_filled"
            ApplicationDataManager.sharedInstance.createFavoritedPOI(poi)
        } else {
            self.favoriteImageName = "star"
            ApplicationDataManager.sharedInstance.removeFavoritedPOI(poi)
        }
    }
    
    /**
    Returns the banner string based on whether this item is favorited or not
    */
    func bannerString() -> String {
        
        if isFavorited {
            return poi.name + NSLocalizedString(" has been added to your list", comment: "")
        } else {
            return poi.name + NSLocalizedString(" has been removed from your list", comment: "")
        }
    }
}
