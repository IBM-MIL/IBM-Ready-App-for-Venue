/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreData

/// Class to represent a Group object
class Group: NSObject {
    let id: Int
    let name: String
    
    override init() {
        id = 0
        name = ""
        
        super.init()
    }
    
    convenience init(managedGroup: NSManagedObject) {
        guard let id = managedGroup.valueForKey("id") as? Int, let name = managedGroup.valueForKey("name") as? String else {
            self.init()
            return
        }
        
        self.init(id: id,name: name)
    }
    
    internal init(id: Int, name: String) {
        self.id = id
        self.name = name
        
        super.init()
    }
}