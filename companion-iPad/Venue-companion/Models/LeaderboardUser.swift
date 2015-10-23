//
//  LeaderboardUser.swift
//  Venue-companion
//
//  Created by Kyle Craig on 10/1/15.
//  Copyright © 2015 IBM MIL. All rights reserved.
//

import UIKit

class LeaderboardUser: NSObject {
    
    let id: Int
    let firstName: String
    let lastName: String
    var name: String {return firstName + " " + lastName}
    var initials: String {return String(firstName[firstName.startIndex]) + String(lastName[lastName.startIndex])}
    let pictureURL: String
    let score: Int
    
    init(dictionary: [String: AnyObject]) {
        
        guard let id = dictionary["id"] as? Int,
            let firstName = dictionary["first_name"] as? String,
            let lastName = dictionary["last_name"] as? String,
            let pictureURL = dictionary["avatar"] as? String,
            let score = dictionary["score"] as? Int else {
                abort()
        }
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.pictureURL = pictureURL
        self.score = score
    }

}
