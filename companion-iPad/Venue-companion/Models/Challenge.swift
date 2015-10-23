//
//  Challenge.swift
//  Venue-companion
//
//  Created by Kyle Craig on 9/30/15.
//  Copyright © 2015 IBM MIL. All rights reserved.
//

import UIKit

class Challenge: NSObject {
    
    let id: Int
    let name: String
    let details: String
    let pointValue: Int
    let imageUrl: String
    let thumbnailUrl: String
    let tasksNeeded: [Int]
    
    init(dictionary: [String: AnyObject]) {
        
        guard let id = dictionary["id"] as? Int,
            let name = dictionary["name"] as? String,
            let details = dictionary["details"] as? String,
            let pointValue = dictionary["point_value"] as? Int,
            let imageUrl = dictionary["image_url"] as? String,
            let thumbnailUrl = dictionary["thumbnail_url"] as? String,
            let tasksNeeded = dictionary["tasks_needed"] as? [Int] else {
                abort()
        }
        
        self.id = id
        self.name = name
        self.details = details
        self.pointValue = pointValue
        self.imageUrl = imageUrl
        self.thumbnailUrl = thumbnailUrl
        
        self.tasksNeeded = tasksNeeded
        
    }

}
