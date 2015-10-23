/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreData

/// Class to represent a Challenge object
class Challenge: NSObject{
    let id: Int
    let name: String
    let details: String
    let pointValue: Int
    let imageUrl: String
    let thumbnailUrl: String
    let tasksNeeded: [ChallengeTask]
    
    override init() {
        id = 0
        name = ""
        details = ""
        pointValue = 0
        imageUrl = ""
        thumbnailUrl = ""
        tasksNeeded = [ChallengeTask]()
    }
    
    convenience init(managedChallenge: NSManagedObject) {
        guard let id = managedChallenge.valueForKey("id") as? Int, let name = managedChallenge.valueForKey("name") as? String, let details = managedChallenge.valueForKey("details") as? String, let pointValue = managedChallenge.valueForKey("point_value") as? Int, let thumbnailUrl = managedChallenge.valueForKey("thumbnail_url") as? String, let imageUrl = managedChallenge.valueForKey("image_url") as? String, let tasksNeeded = managedChallenge.valueForKey("tasks_needed") as? Set<NSManagedObject> else {
            self.init()
            return
        }
        self.init(id: id,name: name,details: details,pointValue: pointValue,imageUrl: imageUrl,thumbnailUrl: thumbnailUrl,tasksNeeded: tasksNeeded)
    }
    
    internal init(id: Int, name: String, details: String, pointValue: Int, imageUrl: String, thumbnailUrl: String, tasksNeeded: Set<NSManagedObject>) {
        self.id = id
        self.name = name
        self.details = details
        self.pointValue = pointValue
        self.imageUrl = imageUrl
        self.thumbnailUrl = thumbnailUrl
        self.tasksNeeded = tasksNeeded.map({ChallengeTask(managedChallengeTask: $0)})
        
        super.init()
    }
}