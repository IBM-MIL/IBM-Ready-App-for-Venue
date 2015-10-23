/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import ReactiveCocoa

/**
*  Struct to declare static strings for filter names once
*/
struct FilterType {
    static let All = NSLocalizedString("All Notifications", comment: "n/a")
    static let Invites = NSLocalizedString("Invitations", comment: "n/a")
    static let Notification = NSLocalizedString("Alerts", comment: "n/a")
}

/// View model to handle Notification list, filtering, and sorting
class NotificationsViewModel: NSObject {
  
    var originalAlertList = [Notification]()
    dynamic var alertList = [Notification]()
    var menuItems: [String]  = [FilterType.All, FilterType.Invites, FilterType.Notification]
    dynamic var isMenuVisible = false
    var selectedIndex = 0
    var selectedMenuItem: String {
        get {
            return menuItems[selectedIndex]
        }
    }
    
    override init() {
        super.init()
        
        buildAlertList()
        setupBindings()
    }
    
    /**
    Setup bindings to listen when new notifications or invitations are received
    */
    func setupBindings() {
        RACObserve(UserDataManager.sharedInstance.currentUser, keyPath: "invitationsRecieved").subscribeNextAs({ [weak self] (invitations: [Invitation]) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.buildAlertList()
        })
        
        
        RACObserve(UserDataManager.sharedInstance.currentUser, keyPath: "notificationsRecieved").subscribeNextAs({ [weak self] (notifications: [Notification]) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.originalAlertList = strongSelf.sortNotificationsByTimestamp(notifications)
            let selectedFilter = strongSelf.menuItems[strongSelf.selectedIndex]
            strongSelf.alertList = strongSelf.filterAlertsBy(selectedFilter)
        })
    }
    
    /**
    Begin notification list building
    */
    func buildAlertList() {
        // MFP Call for Notification data
        let notificationManager = NotificationDataManager.sharedInstance
        notificationManager.getNotifications { [weak self] (notificationData: [Notification]) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.appendInvitations()
        }
    }
    
    /**
    Method that adds invitations into the notification list
    
    - parameter originalList: list of notification alerts
    
    - returns: combined list of notifications and invitations
    */
    func appendInvitations(){
        let user = UserDataManager.sharedInstance.currentUser
        let invites = user.invitationsRecieved
        
        for invite in invites {
            // does a notification exist for this invite
            if !invite.hasNotification {
                if let updatedNotification = ApplicationDataManager.sharedInstance.createNotificationFromInvite(invite) {
                    // add invitation to notification object
                    updatedNotification.invitation = invite
                    invite.hasNotification = true
                    UserDataManager.sharedInstance.currentUser.notificationsRecieved.append(updatedNotification)
                }
            }
        }
    }
    
    // MARK: UI / Data configuration methods
    
    /**
    Cell setup method for the filtering menu cells, hides or shows indicator as needed and also changes indicator image based on menu visibility
    
    - parameter row:  row being updated
    - parameter cell: cell being updated
    
    - returns: modified menu cell
    */
    func setupMenuCellAtIndex(row: Int, cell: NotificationMenuTableViewCell) -> NotificationMenuTableViewCell {
        
        cell.menuOptionLabel.text = menuItems[row]
        
        if row == selectedIndex {
            cell.menuIconImageView.hidden = false
            cell.menuOptionLabel.font = UIFont(name: "Lato-Bold", size: 14.0)
        } else {
            cell.menuIconImageView.hidden = true
            cell.menuOptionLabel.font = UIFont(name: "Lato-Light", size: 14.0)
        }
        return cell
    }
    
    /**
    Cell setup method for the alert cells
    
    - parameter row:  row being updated
    - parameter cell: cell being updated
    
    - returns: modified alert cell
    */
    func setupNotificationCellAtIndex(row: Int, cell: NotificationTableViewCell) -> NotificationTableViewCell {

        cell.titleLabel.text = alertList[row].title
        cell.titleLabel.font = UIFont.boldSystemFontOfSize(17.0)
        cell.descriptionLabel.text = alertList[row].message
        cell.timestampLabel.text = alertList[row].timestamp.localizedStringTime()
        cell.readStatus.hidden = !alertList[row].unread
        
        return cell
    }
    
    /**
    Method moves selected filter to beginning of filter table view as well as filtering content
    
    - parameter row:           item in array selected
    - parameter isMenuVisible: boolean to represent filtering menu visibility
    */
    func didSelectMenuItem(row: Int, isMenuVisible: Bool) {
        
        if isMenuVisible && row != selectedIndex {
            selectedIndex = row
            // filter based on new filter
            let selectedFilter = menuItems[row]
            alertList = filterAlertsBy(selectedFilter)
        }
    }
    
    // MARK: Data handling methods
    
    /**
    Filtering method to remove data that doesn't match filter criteria
    
    - parameter type: type to filter alerts by
    
    - returns: list of alerts that have been filtered
    */
    func filterAlertsBy(type: String) -> [Notification] {
        
        switch type {
            case FilterType.All:
                return originalAlertList
            case FilterType.Invites:
                return originalAlertList.filter({ $0.type == "invitation" })
            case FilterType.Notification:
                return originalAlertList.filter({ $0.type == "alert" })
            default:
                return originalAlertList
        }
        
    }
    
    /**
    Simple sorting method by time, newest first
    
    - parameter alertList: list of alerts to sort
    
    - returns: sorted list of alerts
    */
    func sortNotificationsByTimestamp(alertList: [Notification]) -> [Notification] {
        
        return alertList.sort({
            $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedDescending
        })
    }
}
