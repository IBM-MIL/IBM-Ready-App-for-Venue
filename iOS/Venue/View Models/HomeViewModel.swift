/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import ReactiveCocoa

/// View Model to handle a user's POI and the POIs near them
class HomeViewModel: NSObject {
    
    var poiArray = [POI]()
    var adsArray = [Ad]()
    let adDisplayPositions = [4,9,13]
    var userPoiList = [POI]()
    var userCompletePoiList = [POI]()
    var userInvitations = [Invitation]()
    var showMyList = true
    let videoPath = NSBundle.mainBundle().pathForResource("home_video", ofType: "mp4")!
    
    /// Computes whether we have received any data
    var dataPresent: Bool {
        return userPoiList.count + userCompletePoiList.count + userInvitations.count > 0
    }
    
    override init() {
        super.init()
        
        // Ask data manager for array of Ads
        AdDataManager.sharedInstance.getAdData() { [weak self] (adData: [Ad]) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.adsArray = adData
        }

        // Ask data manager for array of POIs
        PoiDataManager.sharedInstance.getPOIData() { [weak self] (poiData: [POI]) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.poiArray = poiData
        }

    }
    
    private func reloadData() {
        
        let user = UserDataManager.sharedInstance.currentUser
        let favorites = user.favorites
        
        self.userPoiList = []
        self.userCompletePoiList = []
        for favorite in favorites {
            if !favorite.isComplete {
                self.userPoiList.append(favorite.favoritedPOI)
            } else {
                self.userCompletePoiList.append(favorite.favoritedPOI)
            }
        }
        
        // Sort data within sections
        self.userPoiList.sortInPlace({ $0.name.localizedCaseInsensitiveCompare($1.name) == NSComparisonResult.OrderedAscending })
        self.userCompletePoiList.sortInPlace({ $0.name.localizedCaseInsensitiveCompare($1.name) == NSComparisonResult.OrderedAscending })
        
        // Load a User's invitations
        self.userInvitations = user.invitationsAccepted + user.invitationsSent
        self.userInvitations.sortInPlace({ $0.timestampToMeet.compare($1.timestampToMeet) == NSComparisonResult.OrderedAscending })
    }
    
    /**
    Calculates rows in a section, taking logic out of viewController
    
    - parameter section: section to evaluate
    
    - returns: number of rows
    */
    func rowsInSection(section: Int) -> Int {
        reloadData()
        
        if showMyList {
            // first 2 sections are used for UI only
            switch(section) {
            case 0:
                return 0
            case 1:
                return 0
            case 2:
                return userInvitations.count
            case 3:
                return userPoiList.count
            case 4:
                return userCompletePoiList.count
            default:
                return 0
            }
            
        } else {
            return section == 0 ? 0 : poiArray.count + adsArray.count
        }
    }
    
    /**
    Method handles lots of UI logic for all the different types of POIs we can have
    
    - parameter cell:      cell to update
    - parameter indexPath: indexPath to evaluate data for
    */
    func setupPOICell(cell: POITableViewCell, indexPath: NSIndexPath) {
        
        
        if displaysAd(indexPath) {
            let currentAd = adsArray[numberOfAdsPreviouslyDisplayed(indexPath)]
            cell.mainTitleLabel.text = currentAd.name
            cell.typeImageView.image = UIImage(named: "Icons_Home_Ad")
            cell.subtitleLabel.text = currentAd.details
            cell.showWaitLabel()
            cell.toggleWaitTimeHidden(true)
            cell.subtitleLabel.textColor = UIColor.venueLightBlue()
            cell.mainTitleLabel.accessibilityIdentifier = "ad"
            cell.locationImageView.image = UIImage(named: currentAd.thumbnailUrl)
        }
        else {
            
            // Based on different views, display correct POI item
            let currentPOI = getDisplayedPOI(indexPath)
            
            cell.locationImageView.image = UIImage(named: currentPOI.thumbnailUrl)
            cell.mainTitleLabel.text = currentPOI.name
            let firstType = currentPOI.types.first!
            cell.typeImageView.image = UIImage(named: firstType.home_icon_image_name)
            
            /* Logic to display various label variations, colors, and positions */
            
            let waitString = NSLocalizedString("min wait", comment: "")
            if currentPOI.wait_time >= 0 {
                
                // Set text and ensure all labels are visible
                cell.subtitleLabel.text = "\(currentPOI.wait_time) \(waitString)"
                cell.showWaitLabel()
                
                // if we have a wait time, just append invite time onto it
                if indexPath.section == 2 {
                    
                    configureMeetingTime(cell, indexPath: indexPath, shouldAppend: true)
                    cell.subtitleLabel.textColor = UIColor.venueLightBlue()
                } else {
                    
                    // Only change color for items not in Invitations
                    cell.subtitleLabel.updateTextColor(currentPOI.wait_time)
                    cell.waitTimeImageView.image = cell.waitTimeImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    cell.waitTimeImageView.tintColor = cell.subtitleLabel.textColor
                    cell.toggleWaitTimeHidden(false)
                }
                
            } else if indexPath.section == 2 {
                
                // Wait time is less than zero, so we ignore that time
                configureMeetingTime(cell, indexPath: indexPath, shouldAppend: false)
                cell.subtitleLabel.textColor = UIColor.venueLightBlue()
                cell.showWaitLabel()
            } else {
                
                // There should be no subtitle if no wait time and not an invitation
                cell.subtitleLabel.text = ""
                cell.toggleWaitTimeHidden(true)
                
                // No wait label content, so we hide
                cell.hideWaitLabel()
            }
            
        }
    }
    
    /**
    Convenience method to set subtitle label in the right format
    
    - parameter cell:         cell to modify
    - parameter indexPath:    indexPath for current cell
    - parameter shouldAppend: value determining whether new text values should be appended onto the current ones
    */
    func configureMeetingTime(cell: POITableViewCell, indexPath: NSIndexPath, shouldAppend: Bool) {
        
        let currentInvite = userInvitations[indexPath.row]
        
        if shouldAppend {
            cell.subtitleLabel.text! += " | " + currentInvite.timestampToMeet.localizedStringTime()
        } else {
            cell.subtitleLabel.text! = currentInvite.timestampToMeet.localizedStringTime()
        }
        cell.toggleWaitTimeHidden(true)
    }
    

    
    /**
    Helper method to retrieve a `POI` object from the various data structures
    
    - parameter indexPath: used to find correct POI
    
    - returns: the desired `POI` object
    */
    func getDisplayedPOI(indexPath: NSIndexPath) -> POI {
        if showMyList {
            switch(indexPath.section) {
            case 2:
                return userInvitations[indexPath.row].location
            case 3:
                return userPoiList[indexPath.row]
            case 4:
                return userCompletePoiList[indexPath.row]
            default:
                return userCompletePoiList[indexPath.row]
            }
        } else {
            return poiArray[indexPath.row - numberOfAdsPreviouslyDisplayed(indexPath)]
        }
    }
    
    /**
    Calculates number of ads already in POI list
    
    - parameter indexPath: used to check section number
    
    - returns: calculated number of ads
    */
    func numberOfAdsPreviouslyDisplayed(indexPath: NSIndexPath) -> Int {
        if showMyList || indexPath.section != 1 {
            return 0
        }
        return adDisplayPositions.filter({$0 < indexPath.row}).count
    }
    
    /**
    Determines if we should display an ad, we have 3 to show
    
    - parameter indexPath: checking for indexPath
    
    - returns: boolean result
    */
    func displaysAd(indexPath: NSIndexPath) -> Bool {
        if showMyList || indexPath.section != 1 {
            return false
        }
        else {
            return adDisplayPositions.indexOf(indexPath.row) != nil
        }
    }

}
