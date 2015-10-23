/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreData

/// Class to represent a Detail object
class Detail: NSObject {
    let id: Int
    let message: String
    let image_name: String
    
    override init() {
        id = 0
        message = ""
        image_name = ""
        
        super.init()
    }
    
    convenience init(managedDetail: NSManagedObject) {
        guard let id = managedDetail.valueForKey("id") as? Int, let message = managedDetail.valueForKey("message") as? String, let image_name = managedDetail.valueForKey("image_name") as? String else {
            self.init()
            return
        }
        self.init(id: id,message: message,image_name: image_name)
    }
    
    internal init(id: Int, message: String, image_name: String) {
        self.id = id
        self.message = message
        self.image_name = image_name
        
        super.init()
    }
}