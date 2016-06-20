/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreData

/// Class to represent a User object
class User: NSObject {
    
    let id: Int
    let deviceId: String
    let email: String
    var name: String {return first_name + " " + last_name}
    var initials: String {return String(first_name[first_name.startIndex]) + String(last_name[last_name.startIndex])}
    let first_name: String
    let last_name: String
    let phoneNumber: String
    let pictureUrl: String
    let currentLocationX: Double
    let currentLocationY: Double
    var currentLocationName: String?
    dynamic var tasksCompleted: [ChallengeTask]
    dynamic var challengesCompleted: [Challenge]
    dynamic var notificationsRecieved: [Notification]
    dynamic var invitationsSent: [Invitation]
    dynamic var invitationsRecieved: [Invitation]
    dynamic var invitationsAccepted: [Invitation]
    let group: Group
    dynamic var favorites: [FavoritedPOI]
    var score: Int {
        get {
            var sum: Int = 0
            for challenge in challengesCompleted {
                sum += challenge.pointValue
            }
            return sum
        }
    }
    
    override init() {
        id = 0
        deviceId = ""
        email = ""
        first_name = ""
        last_name = ""
        phoneNumber = ""
        pictureUrl = ""
        currentLocationX = 0
        currentLocationY = 0
        tasksCompleted = [ChallengeTask]()
        challengesCompleted = [Challenge]()
        notificationsRecieved = [Notification]()
        invitationsSent = [Invitation]()
        invitationsRecieved = [Invitation]()
        invitationsAccepted = [Invitation]()
        group = Group()
        favorites = [FavoritedPOI]()
        
        super.init()
    }
    
    convenience init(managedUser: NSManagedObject) {
        guard let id = managedUser.valueForKey("id") as? Int, let deviceId = managedUser.valueForKey("device_id") as? String, let email = managedUser.valueForKey("email") as? String, let first_name = managedUser.valueForKey("first_name") as? String, let last_name = managedUser.valueForKey("last_name") as? String, let phoneNumber = managedUser.valueForKey("phone_number") as? String, let pictureUrl = managedUser.valueForKey("picture_url") as? String, let currentLocationX = managedUser.valueForKey("current_location_x") as? Double, let currentLocationY = managedUser.valueForKey("current_location_y") as? Double, let tasksCompleted = managedUser.valueForKey("tasks_completed") as? Set<NSManagedObject>, let challengesCompleted = managedUser.valueForKey("challenges_completed") as? Set<NSManagedObject>, let notificationsRecieved = managedUser.valueForKey("notifications_recieved") as? Set<NSManagedObject>, let invitationsSent = managedUser.valueForKey("invitations_sent") as? Set<NSManagedObject>, let invitationsAccepted = managedUser.valueForKey("invitations_accepted") as? Set<NSManagedObject>, let invitationsRecieved = managedUser.valueForKey("invitations_recieved") as? Set<NSManagedObject>, let group = managedUser.valueForKey("group") as? NSManagedObject, let favorites = managedUser.valueForKey("favorites") as? Set<NSManagedObject> else {
            self.init()
            return
        }
        self.init(id: id,deviceId: deviceId,email: email,first_name: first_name,last_name: last_name,phoneNumber: phoneNumber,pictureUrl: pictureUrl,currentLocationX: currentLocationX,currentLocationY: currentLocationY,tasksCompleted: tasksCompleted,challengesCompleted: challengesCompleted,notificationsRecieved: notificationsRecieved,group: group,favorites: favorites,invitationsSent: invitationsSent,invitationsAccepted: invitationsAccepted,invitationsRecieved: invitationsRecieved)
    }
    
    init(id: Int, deviceId: String, email: String, first_name: String, last_name: String, phoneNumber: String, pictureUrl: String, currentLocationX: Double, currentLocationY: Double, tasksCompleted: Set<NSManagedObject>, challengesCompleted: Set<NSManagedObject>, notificationsRecieved: Set<NSManagedObject>, group: NSManagedObject, favorites: Set<NSManagedObject>, invitationsSent: Set<NSManagedObject>, invitationsAccepted: Set<NSManagedObject>, invitationsRecieved: Set<NSManagedObject>) {
        self.id = id
        self.deviceId = deviceId
        self.email = email
        self.first_name = first_name
        self.last_name = last_name
        self.phoneNumber = phoneNumber
        self.pictureUrl = pictureUrl
        self.currentLocationX = currentLocationX
        self.currentLocationY = currentLocationY
        
        self.tasksCompleted = tasksCompleted.map({ChallengeTask(managedChallengeTask: $0)})
        self.challengesCompleted = challengesCompleted.map({Challenge(managedChallenge: $0)})
        self.notificationsRecieved = notificationsRecieved.map({Notification(managedNotification: $0)})
        self.group = Group(managedGroup: group)
        self.favorites = favorites.map({FavoritedPOI(managedFavoritedPOI: $0)})
        self.invitationsSent = invitationsSent.map({Invitation(managedInvitation: $0)})
        self.invitationsAccepted = invitationsAccepted.map({Invitation(managedInvitation: $0)})
        self.invitationsRecieved = invitationsRecieved.map({Invitation(managedInvitation: $0)})
        
        super.init()
    }
    
    // Update to use CGPoint instead of location name
    func updateUserLocation(callback: (CGPoint)->()) {
        // Get the user's current location
        callback(CGPoint(x: currentLocationX,y: currentLocationY))
    }
    
}