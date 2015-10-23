//
//  User.swift
//  Venue-companion
//
//  Created by Kyle Craig on 9/30/15.
//  Copyright © 2015 IBM MIL. All rights reserved.
//

import UIKit

class User: NSObject {
    
    let id: Int
    let group: Int
    let deviceId: String
    let firstName: String
    let lastName: String
    var name: String {return firstName + " " + lastName}
    var initials: String {return String(firstName[firstName.startIndex]) + String(lastName[lastName.startIndex])}
    let pictureURL: String
    var currentLocationX: Double
    var currentLocationY: Double
    var tasksCompleted: [ChallengeTask]
    var challengesCompleted: [Challenge]
    var score: Int {
        get {
            var sum: Int = 0
            for challenge in challengesCompleted {
                sum += challenge.pointValue
            }
            return sum
        }
    }
    var plans: [POI]
    
    init(dictionary: [String: AnyObject]) {
        
        guard let id = dictionary["id"] as? Int,
            let group = dictionary["group"] as? Int,
            let deviceId = dictionary["device_id"] as? String,
            let firstName = dictionary["first_name"] as? String,
            let lastName = dictionary["last_name"] as? String,
            let pictureURL = dictionary["picture_url"] as? String,
            let currentLocationX = dictionary["current_location_x"] as? Double,
            let currentLocationY = dictionary["current_location_y"] as? Double,
            let tasksCompleted = dictionary["tasks_completed"] as? [Int],
            let challengesCompleted = dictionary["challenges_completed"] as? [Int],
            let plans = dictionary["plans"] as? [Int] else {
                abort()
        }
        
        self.id = id
        self.group = group
        self.deviceId = deviceId
        self.firstName = firstName
        self.lastName = lastName
        self.pictureURL = pictureURL
        self.currentLocationX = currentLocationX
        self.currentLocationY = currentLocationY
        
        self.tasksCompleted = []
        for task in ApplicationDataManager.sharedInstance.tasks {
            for taskID in tasksCompleted {
                if task.id == taskID {
                    self.tasksCompleted.append(task)
                }
            }
        }
        
        self.challengesCompleted = []
        for challenge in ApplicationDataManager.sharedInstance.challenges {
            for challengeID in challengesCompleted {
                if challenge.id == challengeID {
                    self.challengesCompleted.append(challenge)
                }
            }
        }
        
        self.plans = []
        for poi in ApplicationDataManager.sharedInstance.pois {
            for poiID in plans {
                if poi.id == poiID {
                    self.plans.append(poi)
                }
            }
        }
        
        
    }

}
