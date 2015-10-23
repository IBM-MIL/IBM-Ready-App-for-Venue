/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreData

/// Class to represent a POI object
class POI: NSObject {
    let id: Int
    let coordinateX: Double
    let coordinateY: Double
    let descriptionDetail: String
    let name: String
    let pictureUrl: String
    let thumbnailUrl: String
    let height_requirement: Int
    let wait_time: Int
    var types: [Type]
    var details: [Detail]
    
    override init() {
        id = 0
        coordinateX = 0
        coordinateY = 0
        descriptionDetail = ""
        name = ""
        pictureUrl = ""
        thumbnailUrl = ""
        height_requirement = 0
        wait_time = 0
        types = [Type]()
        details = [Detail]()
    }
    
    convenience init(managedPOI: NSManagedObject) {
        guard let id = managedPOI.valueForKey("id") as? Int, let coordinateX = managedPOI.valueForKey("coordinate_x") as? Double, let coordinateY = managedPOI.valueForKey("coordinate_y") as? Double, let name = managedPOI.valueForKey("name") as? String, let descriptionDetail = managedPOI.valueForKey("description_detail") as? String, let pictureUrl = managedPOI.valueForKey("picture_url") as? String, let thumbnailUrl = managedPOI.valueForKey("thumbnail_url") as? String, let height_requirement = managedPOI.valueForKey("height_requirement") as? Int, let wait_time = managedPOI.valueForKey("wait_time") as? Int, let types = managedPOI.valueForKey("types") as? Set<NSManagedObject>, let details = managedPOI.valueForKey("details") as? Set<NSManagedObject> else {
            self.init()
            return
        }
        self.init(id: id,coordinateX: coordinateX,coordinateY: coordinateY,descriptionDetail: descriptionDetail,name: name,pictureUrl: pictureUrl,thumbnailUrl: thumbnailUrl,height_requirement: height_requirement,wait_time: wait_time,types: types,details: details)
    }
    
    internal init(id: Int, coordinateX: Double, coordinateY: Double, descriptionDetail: String, name: String, pictureUrl: String, thumbnailUrl: String, height_requirement: Int, wait_time: Int, types: Set<NSManagedObject>,details: Set<NSManagedObject>) {
        self.id = id
        self.coordinateX = coordinateX
        self.coordinateY = coordinateY
        self.descriptionDetail = descriptionDetail
        self.name = name
        self.pictureUrl = pictureUrl
        self.thumbnailUrl = thumbnailUrl
        self.height_requirement = height_requirement
        self.wait_time = wait_time
        self.types = types.map({Type(managedType: $0)})
        self.details = details.map({Detail(managedDetail: $0)})
        
        // Sort types by id of type
        self.types.sortInPlace({$0.id < $1.id})
        
        super.init()
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