/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

// MARK: - ParsingManager extension to help parse json file into Core Data objects the app saves locally

extension ApplicationDataManager {
    
    func parseJsonObjectIntoCoreData(jsonObject: [String: AnyObject]) {
        parseNotificiations(jsonObject)
        parseGroups(jsonObject)
        parseChallengeTasks(jsonObject)
        parseChallenges(jsonObject)
        parseTypes(jsonObject)
        parseDetails(jsonObject)
        parsePOIs(jsonObject)
        parseFavoritedPOIs(jsonObject)
        parseUsers(jsonObject)
        parseInvitations(jsonObject)
        parseAds(jsonObject)
        
        isDoneLoading = true
    }
    
    private func parseNotificiations(jsonObject: [String: AnyObject]) {
        guard let notificationsArray = jsonObject["notifications"] as? [[String: AnyObject]] else {
            print("Data parser: Notifications data not recieved or malformed")
            return
        }
        for notificationDictionary in notificationsArray {
            guard let managedNotification = createManagedObject("Notification") else {
                return
            }
            
            managedNotification.setValue(notificationDictionary["id"] as! Int, forKey: "id")
            managedNotification.setValue(notificationDictionary["title"], forKey: "title")
            managedNotification.setValue(notificationDictionary["message"], forKey: "message")
            managedNotification.setValue(notificationDictionary["unread"] as! String == "true", forKey: "unread")
            managedNotification.setValue(notificationDictionary["type"] as! String, forKey: "type")
            managedNotification.setValue(NSDate(timeIntervalSince1970: notificationDictionary["timestamp"] as! NSTimeInterval), forKey: "timestamp")
            
            saveToCoreData()
        }
    }
    
    private func parseGroups(jsonObject: [String: AnyObject]) {
        guard let groupsArray = jsonObject["groups"] as? [[String: AnyObject]] else {
            print("Data parser: Groups data not recieved or malformed")
            return
        }
        
        for groupDictionary in groupsArray {
            guard let managedGroup = createManagedObject("Group") else {
                return
            }
            
            managedGroup.setValue(groupDictionary["id"], forKey: "id")
            managedGroup.setValue(groupDictionary["name"], forKey: "name")
            
            saveToCoreData()
        }
    }
    
    private func parseChallengeTasks(jsonObject: [String: AnyObject]) {
        guard let challengeTasksArray = jsonObject["challengeTasks"] as? [[String: AnyObject]] else {
            print("Data parser: Challenge Tasks data not recieved or malformed")
            return
        }
        for challengeTaskDictionary in challengeTasksArray {
            guard let managedChallengeTask = createManagedObject("ChallengeTask") else {
                return
            }
            
            managedChallengeTask.setValue(challengeTaskDictionary["id"], forKey: "id")
            managedChallengeTask.setValue(challengeTaskDictionary["name"], forKey: "name")
            
            saveToCoreData()
        }
    }
    
    private func parseChallenges(jsonObject: [String: AnyObject]) {
        guard let challengesArray = jsonObject["challenges"] as? [[String: AnyObject]] else {
            print("Data parser: Challenges data not recieved or malformed")
            return
        }
        for challengeDictionary in challengesArray {
            guard let managedChallenge = createManagedObject("Challenge") else {
                return
            }
            
            managedChallenge.setValue(challengeDictionary["id"], forKey: "id")
            managedChallenge.setValue(challengeDictionary["name"], forKey: "name")
            managedChallenge.setValue(challengeDictionary["details"], forKey: "details")
            managedChallenge.setValue(challengeDictionary["image_url"], forKey: "image_url")
            managedChallenge.setValue(challengeDictionary["point_value"], forKey: "point_value")
            managedChallenge.setValue(challengeDictionary["thumbnail_url"], forKey: "thumbnail_url")
            
            let tasksNeeded = Set(fetchFromCoreData("ChallengeTask", ids: challengeDictionary["tasks_needed"] as! [Int]))
            managedChallenge.setValue(tasksNeeded, forKey: "tasks_needed")
            
            saveToCoreData()
        }
    }
    
    private func parseTypes(jsonObject: [String: AnyObject]) {
        guard let typesArray = jsonObject["types"] as? [[String: AnyObject]] else {
            print("Data parser: Type data not recieved or malformed")
            return
        }
        for typeDictionary in typesArray {
            guard let managedType = createManagedObject("Type") else {
                return
            }
            
            managedType.setValue(typeDictionary["id"], forKey: "id")
            managedType.setValue(typeDictionary["name"], forKey: "name")
            managedType.setValue(typeDictionary["image_name"], forKey: "image_name")
            managedType.setValue(typeDictionary["pin_image_name"], forKey: "pin_image_name")
            
            saveToCoreData()
        }
    }
    
    private func parseDetails(jsonObject: [String: AnyObject]) {
        guard let detailsArray = jsonObject["details"] as? [[String: AnyObject]] else {
            print("Data parser: Detail data not recieved or malformed")
            return
        }
        for detailDictionary in detailsArray {
            guard let managedDetail = createManagedObject("Detail") else {
                return
            }
            
            managedDetail.setValue(detailDictionary["id"], forKey: "id")
            managedDetail.setValue(detailDictionary["message"], forKey: "message")
            managedDetail.setValue(detailDictionary["image_name"], forKey: "image_name")
            
            saveToCoreData()
        }
    }
    
    private func parsePOIs(jsonObject: [String: AnyObject]) {
        guard let POIsArray = jsonObject["POIs"] as? [[String: AnyObject]] else {
            print("Data parser: POIs data not recieved or malformed")
            return
        }
        for POIDictionary in POIsArray {
            guard let managedPOI = createManagedObject("POI") else {
                return
            }
            
            managedPOI.setValue(POIDictionary["id"], forKey: "id")
            managedPOI.setValue(POIDictionary["coordinate_x"], forKey: "coordinate_x")
            managedPOI.setValue(POIDictionary["coordinate_y"], forKey: "coordinate_y")
            managedPOI.setValue(POIDictionary["description"], forKey: "description_detail")
            managedPOI.setValue(POIDictionary["name"], forKey: "name")
            managedPOI.setValue(POIDictionary["picture_url"], forKey: "picture_url")
            managedPOI.setValue(POIDictionary["thumbnail_url"], forKey: "thumbnail_url")
            managedPOI.setValue(POIDictionary["wait_time"], forKey: "wait_time")
            managedPOI.setValue(POIDictionary["height_requirement"], forKey: "height_requirement")
            
            let types = Set(fetchFromCoreData("Type", ids: POIDictionary["types"] as! [Int]))
            managedPOI.setValue(types, forKey: "types")
            
            let details = Set(fetchFromCoreData("Detail", ids: POIDictionary["details"] as! [Int]))
            managedPOI.setValue(details, forKey: "details")
            
            saveToCoreData()
        }
    }
    
    private func parseFavoritedPOIs(jsonObject: [String: AnyObject]) {
        guard let FavoritedPOIsArray = jsonObject["favoritedPOIs"] as? [[String: AnyObject]] else {
            print("Data parser: POIs data not recieved or malformed")
            return
        }
        for FavoritedPOIDictionary in FavoritedPOIsArray {
            guard let managedFavoritedPOI = createManagedObject("FavoritedPOI") else {
                return
            }
            
            managedFavoritedPOI.setValue(FavoritedPOIDictionary["id"], forKey: "id")
            managedFavoritedPOI.setValue(FavoritedPOIDictionary["complete"], forKey: "complete")
            let poi_favorited = fetchFromCoreData("POI", id: FavoritedPOIDictionary["poi_favorited"] as! Int)
            managedFavoritedPOI.setValue(poi_favorited, forKey: "poi_favorited")
            
            saveToCoreData()
        }
    }
    
    private func parseUsers(jsonObject: [String: AnyObject]) {
        guard let UsersArray = jsonObject["users"] as? [[String: AnyObject]] else {
            print("Data parser: Users data not recieved or malformed")
            return
        }
        for userDictionary in UsersArray {
            guard let managedUser = createManagedObject("User") else {
                return
            }
            
            managedUser.setValue(userDictionary["id"], forKey: "id")
            managedUser.setValue(userDictionary["device_id"], forKey: "device_id")
            managedUser.setValue(userDictionary["email"], forKey: "email")
            managedUser.setValue(userDictionary["first_name"], forKey: "first_name")
            managedUser.setValue(userDictionary["last_name"], forKey: "last_name")
            managedUser.setValue(userDictionary["phone_number"], forKey: "phone_number")
            managedUser.setValue(userDictionary["picture_url"], forKey: "picture_url")
            managedUser.setValue(userDictionary["current_location_x"], forKey: "current_location_x")
            managedUser.setValue(userDictionary["current_location_y"], forKey: "current_location_y")
            
            let challengesCompleted = Set(fetchFromCoreData("Challenge", ids: userDictionary["challenges_completed"] as! [Int]))
            managedUser.setValue(challengesCompleted, forKey: "challenges_completed")
            
            let tasksCompleted = Set(fetchFromCoreData("ChallengeTask", ids: userDictionary["tasks_completed"] as! [Int]))
            managedUser.setValue(tasksCompleted, forKey: "tasks_completed")
            
            let notificationsRecieved = Set(fetchFromCoreData("Notification", ids: userDictionary["notifications_recieved"] as! [Int]))
            managedUser.setValue(notificationsRecieved, forKey: "notifications_recieved")
            
            let group = fetchFromCoreData("Group", id: userDictionary["group"] as! Int)
            managedUser.setValue(group, forKey: "group")
            
            let favorites = Set(fetchFromCoreData("FavoritedPOI", ids: userDictionary["favorites"] as! [Int]))
            managedUser.setValue(favorites, forKey: "favorites")
            
            saveToCoreData()
        }
    }
    
    private func parseInvitations(jsonObject: [String: AnyObject]) {
        guard let invitationsArray = jsonObject["invitations"] as? [[String: AnyObject]] else {
            print("Data parser: Invitations data not recieved or malformed")
            return
        }
        for invitationDictionary in invitationsArray {
            guard let managedInvitation = createManagedObject("Invitation"), let epochTimeSent = invitationDictionary["timestamp_sent"] as? NSTimeInterval, let epochTimeToMeet = invitationDictionary["timestamp_to_meet"] as? NSTimeInterval, let senderId = invitationDictionary["sender"] as? Int, let locationId = invitationDictionary["location"] as? Int else {
                return
            }
            
            managedInvitation.setValue(invitationDictionary["id"], forKey: "id")
            managedInvitation.setValue(NSDate(timeIntervalSince1970: epochTimeSent) , forKey: "timestamp_sent")
            managedInvitation.setValue(NSDate(timeIntervalSince1970: epochTimeToMeet) , forKey: "timestamp_to_meet")
            
            guard let location = fetchFromCoreData("POI", id: locationId) else {
                return
            }
            managedInvitation.setValue(location, forKey: "location")
            
            guard let sender = fetchFromCoreData("User", id: senderId) else {
                return
            }
            managedInvitation.setValue(sender, forKey: "sender")
            
            let recipients = Set(fetchFromCoreData("User", ids: invitationDictionary["recipients"] as! [Int]))
            managedInvitation.setValue(recipients, forKey: "recipients")
            
            saveToCoreData()
        }
    }
    
    private func parseAds(jsonObject: [String: AnyObject]) {
        guard let adsArray = jsonObject["ads"] as? [[String: AnyObject]] else {
            print("Data parser: Ads data not recieved or malformed")
            return
        }
        for adDictionary in adsArray {
            guard let managedAd = createManagedObject("Ad") else {
                return
            }
            managedAd.setValue(adDictionary["id"], forKeyPath: "id")
            managedAd.setValue(adDictionary["name"], forKeyPath: "name")
            managedAd.setValue(adDictionary["thumbnail_url"], forKeyPath: "thumbnail_url")
            managedAd.setValue(adDictionary["details"], forKeyPath: "details")
            
            saveToCoreData()
        }
    }

}