/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import CoreSpotlight
import MobileCoreServices

// MARK: - LoadingManager extension to read data from Core Data and convert to Swift objects

extension ApplicationDataManager {
    
    // MARK: - Load From CoreData to Swift Objects
    
    func loadNotificationsFromCoreData() -> [Notification] {
        var notifications = [Notification]()
        let managedNotifications = fetchAllFromCoreData("Notification")
        for managedNotification in managedNotifications {
            notifications.append(Notification(managedNotification: managedNotification))
        }
        
        return notifications
    }
    
    func loadUsersFromCoreData() -> [User] {
        var users = [User]()
        let managedUsers = fetchAllFromCoreData("User")
        for managedUser in managedUsers {
            users.append(User(managedUser: managedUser))
        }
        
        // sort alphabetically by last name
        
        users.sortInPlace({$0.last_name < $1.last_name})
        
        return users
    }
    
    func loadPOIsFromCoreData() -> [POI] {
        var POIs = [POI]()
        let managedPOIs = fetchAllFromCoreData("POI")
        for managedPOI in managedPOIs {
            POIs.append(POI(managedPOI: managedPOI))
        }
        
        // MARK: iOS Search - Deep Linking
        
        // Creates a searchable set for iOS9 for each POI.
        if #available(iOS 9.0, *) {
            var searchableItems: [CSSearchableItem] = []
            for poi in POIs {
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
                
                attributeSet.title = poi.name
                
                if poi.types.count > 0 {
                    attributeSet.contentDescription = poi.descriptionDetail
                }
                
                var keywords: [String] = []
                for type in poi.types {
                    keywords.append(type.name)
                }
                attributeSet.keywords = keywords
                
                searchableItems.append(CSSearchableItem(uniqueIdentifier: poi.name, domainIdentifier: "Brickland POIs", attributeSet: attributeSet))
            }
            
            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems) { (error) -> Void in
                if error != nil {
                    print("Error creating searchable index: \(error?.localizedDescription)")
                }
            }
        }
        return POIs
    }
    
    func loadChallengesFromCoreData() -> [Challenge] {
        var challenges = [Challenge]()
        let managedChallenges = fetchAllFromCoreData("Challenge")
        for managedChallenge in managedChallenges {
            challenges.append(Challenge(managedChallenge: managedChallenge))
        }
        
        return challenges
    }
    
    func loadInvitationsFromCoreData() -> [Invitation] {
        var invitations = [Invitation]()
        let managedInvitations = fetchAllFromCoreData("Invitation")
        for managedInvitation in managedInvitations {
            let invitation = Invitation(managedInvitation: managedInvitation)
            invitations.append(invitation)
        }
        
        return invitations
    }
    
    func loadPoiTypesFromCoreData() -> [Type] {
        var poiTypes = [Type]()
        let managedTypes = fetchAllFromCoreData("Type")
        for managedType in managedTypes {
            poiTypes.append(Type(managedType: managedType))
        }
        
        return poiTypes
    }
    
    func loadAdsFromCoreData() -> [Ad] {
        let managedAds = fetchAllFromCoreData("Ad")
        return managedAds.map({Ad(managedAd: $0)})
    }
}
