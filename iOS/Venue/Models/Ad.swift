/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreData

/// Class to represent an Ad object
class Ad: NSObject {
    let id: Int
    let name: String
    let details: String
    let thumbnailUrl: String
    
    override init() {
        id = 0
        name = ""
        details = ""
        thumbnailUrl = ""
        
        super.init()
    }
    
    convenience init(managedAd: NSManagedObject) {
        guard let id = managedAd.valueForKey("id") as? Int, let name = managedAd.valueForKey("name") as? String, let details = managedAd.valueForKey("details") as? String, let thumbnailUrl = managedAd.valueForKey("thumbnail_url") as? String else {
            self.init()
            return
        }
        self.init(id: id,name: name,details: details,thumbnailUrl: thumbnailUrl)
    }
    
    internal init(id: Int, name: String, details: String, thumbnailUrl: String) {
        self.id = id
        self.name = name
        self.details = details
        self.thumbnailUrl = thumbnailUrl
        
        super.init()
    }
}