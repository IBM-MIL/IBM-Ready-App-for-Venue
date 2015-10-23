//
//  ChallengeTask.swift
//  Venue-companion
//
//  Created by Kyle Craig on 9/30/15.
//  Copyright © 2015 IBM MIL. All rights reserved.
//

import UIKit

class ChallengeTask: NSObject {
    
    let id: Int
    let name: String
    
    init(dictionary: [String: AnyObject]) {
        guard let id = dictionary["id"] as? Int,
            let name = dictionary["name"] as? String else {
            abort()
        }
        
        self.id = id
        self.name = name
    }

}
