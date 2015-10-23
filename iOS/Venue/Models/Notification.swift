/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreData

/// Class to represent a Notification object
class Notification: NSObject {
    let id: Int
    var title: String
    let message: String
    dynamic var unread: Bool
    let type: String
    let timestamp: NSDate
    
    // Optinal invitation property used in notification screen
    var invitation: Invitation?
    
    override init() {
        id = 0
        title = ""
        message = ""
        unread = false
        type = ""
        timestamp =  NSDate()
        
        super.init()
    }
    
    convenience init(managedNotification: NSManagedObject) {
        guard let id = managedNotification.valueForKey("id") as? Int,
            let title = managedNotification.valueForKey("title") as? String,
            let message = managedNotification.valueForKey("message") as? String,
            let unread = managedNotification.valueForKey("unread") as? Bool,
            let type = managedNotification.valueForKey("type") as? String,
            let timestamp = managedNotification.valueForKey("timestamp") as? NSDate else {
                self.init()
                return
        }
        self.init(id: id,title: title,message: message,unread: unread,type: type,timestamp: timestamp)
    }
    
    internal init(id: Int, title: String, message: String,  unread: Bool, type: String, timestamp: NSDate) {
        self.id = id
        self.title = title
        self.message = message
        self.unread = unread
        self.type = type
        self.timestamp = timestamp
        
        super.init()
        
        RACObserve(self, keyPath: "unread").subscribeNext({(_: AnyObject!)
            in
            ApplicationDataManager.sharedInstance.saveNotification(self)
        })
    }

}