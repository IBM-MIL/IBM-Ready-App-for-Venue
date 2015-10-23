//
//  POI.swift
//  Venue-companion
//
//  Created by Kyle Craig on 9/30/15.
//  Copyright © 2015 IBM MIL. All rights reserved.
//

import UIKit

class POI: NSObject {
    let id: Int
    var coordinateX: Double
    var coordinateY: Double
    let descriptionDetail: String
    let name: String
    let pictureUrl: String
    let thumbnailUrl: String
    var types: [POIType]
    
    init(dictionary: [String: AnyObject]) {
        guard let id = dictionary["id"] as? Int,
            let coordinateX = dictionary["coordinate_x"] as? Int,
            let coordinateY = dictionary["coordinate_y"] as? Int,
            let name = dictionary["name"] as? String,
            let descriptionDetail = dictionary["description"] as? String,
            let pictureUrl = dictionary["picture_url"] as? String,
            let thumbnailUrl = dictionary["thumbnail_url"] as? String,
            let types = dictionary["types"] as? [Int] else {
            abort()
        }
        self.id = id
        self.coordinateX = Double(coordinateX)
        self.coordinateY = Double(coordinateY)
        self.descriptionDetail = descriptionDetail
        self.name = name
        self.pictureUrl = pictureUrl
        self.thumbnailUrl = thumbnailUrl
        
        self.types = []
        for type in ApplicationDataManager.sharedInstance.types {
            for typeID in types {
                if type.id == typeID {
                    self.types.append(type)
                }
            }
        }
        
    }
    
    func getFirstTypeString() -> String {
        if let firstType = self.types.first {
            var typeName = firstType.name
            let lastChar = typeName.characters.last!
            if lastChar == "s"  {
                typeName.removeAtIndex(typeName.endIndex.advancedBy(-1))
            }
            return typeName
        }
        return ""
    }

}
