/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreData

/// Class to represent an Invitation object
class Invitation: NSObject {
    let id: Int
    let timestampSent: NSDate
    let timestampToMeet: NSDate
    let location: POI
    var hasNotification = false
    
    override init() {
        id = 0
        timestampSent = NSDate()
        timestampToMeet = NSDate()
        location = POI()
    }
    
    convenience init(managedInvitation: NSManagedObject) {
        
        guard let id = managedInvitation.valueForKey("id") as? Int,
            let timestampSent = managedInvitation.valueForKey("timestamp_sent") as? NSDate,
            let timestampToMeet = managedInvitation.valueForKey("timestamp_to_meet") as? NSDate,
            let location = managedInvitation.valueForKey("location") as? NSManagedObject else {
            self.init()
                return
        }
        self.init(id: id,timestampSent: timestampSent,timestampToMeet: timestampToMeet,location: location)
        
    }
    
    internal init(id: Int, timestampSent: NSDate, timestampToMeet: NSDate, location: NSManagedObject) {
        self.id = id
        self.timestampSent = timestampSent
        self.timestampToMeet = timestampToMeet
        self.location = POI(managedPOI: location)
        
        super.init()
    }
}