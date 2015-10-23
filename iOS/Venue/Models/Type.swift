/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreData

/// Class to represent a Type object
class Type: NSObject {
    let id: Int
    let name: String
    private let image_name: String
    let pin_image_name: String
    var selected_image_name: String { return image_name + "_Selected" }
    var unselected_image_name: String { return image_name + "_Unselected" }
    var home_icon_image_name: String { return "Icons_Home_" + name }
    var isSelected = false
    var shouldDisplay = true
    
    override init() {
        id = 0
        name = ""
        image_name = ""
        pin_image_name = ""
        
        super.init()
    }
    
    convenience init(managedType: NSManagedObject) {
        guard let id = managedType.valueForKey("id") as? Int, let name = managedType.valueForKey("name") as? String, let image_name = managedType.valueForKey("image_name") as? String, let pin_image_name = managedType.valueForKey("pin_image_name") as? String else {
            self.init()
            return
        }
        self.init(id: id,name: name,image_name: image_name,pin_image_name: pin_image_name)
    }
    
    internal init(id: Int, name: String, image_name: String, pin_image_name: String) {
        self.id = id
        self.name = name
        self.image_name = image_name
        self.pin_image_name = pin_image_name
        
        super.init()
    }
}