/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreData

/// Class to represent a Favorited POI object
class FavoritedPOI: NSObject {
    let id: Int
    let isComplete: Bool
    let favoritedPOI: POI
    
    init(managedFavoritedPOI: NSManagedObject) {
        guard let id = managedFavoritedPOI.valueForKey("id") as? Int, let isComplete = managedFavoritedPOI.valueForKey("complete") as? Bool, let favoritedPOI = managedFavoritedPOI.valueForKey("poi_favorited") as? NSManagedObject else {
            abort()
        }
        self.id = id
        self.isComplete = isComplete
        self.favoritedPOI = POI(managedPOI: favoritedPOI)
    }
}