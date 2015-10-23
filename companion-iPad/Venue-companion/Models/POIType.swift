//
//  POIType.swift
//  Venue-companion
//
//  Created by Kyle Craig on 9/30/15.
//  Copyright © 2015 IBM MIL. All rights reserved.
//

import UIKit

class POIType: NSObject {
    let id: Int
    let name: String
    private let image_name: String
    let pin_image_name: String
    var selected_image_name: String { return image_name + "_Selected" }
    var unselected_image_name: String { return image_name + "_Unselected" }
    var home_icon_image_name: String { return "Icons_Home_" + name }
    var isSelected = false
    var shouldDisplay = true
    
    init(dictionary: [String: AnyObject]) {
        guard let id = dictionary["id"] as? Int,
            let name = dictionary["name"] as? String,
            let image_name = dictionary["image_name"] as? String,
            let pin_image_name = dictionary["pin_image_name"] as? String else {
            abort()
        }
        self.id = id
        self.name = name
        self.image_name = image_name
        self.pin_image_name = pin_image_name
    }

}
