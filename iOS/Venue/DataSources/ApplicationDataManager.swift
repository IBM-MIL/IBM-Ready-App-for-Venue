/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import UIKit
import CoreData
import ReactiveCocoa

class ApplicationDataManager: NSObject {
    
    static let sharedInstance = ApplicationDataManager()
    
    let appDelegate: AppDelegate
    let managedContext: NSManagedObjectContext
    var jsonVersionNumber: Int
    var appVersionNumber: String
    dynamic var isDoneLoading: Bool
    
    private override init() {
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        isDoneLoading = false
        
        // temporarly set to zero for super init
        jsonVersionNumber = 0
        if let appVersionNumber = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersionNumber = appVersionNumber
        }
        else {
            print("Error reading app number")
            appVersionNumber = "0"
        }
        print(appVersionNumber)
        
        super.init()
        
        // check for saved version numbers of json and app
        guard let jsonVersionNumber = NSUserDefaults.standardUserDefaults().objectForKey("jsonVersionNumber") as? Int else {
            guard let filePath = NSBundle.mainBundle().pathForResource("OfflineData", ofType: "json") else {
                return
            }
            if let jsonDictionary = loadDataFromJsonFile(filePath) {
                saveVersionNumber(jsonDictionary)
            }
            return
        }
        self.jsonVersionNumber = jsonVersionNumber
        
    }
    
    // MARK: - JSON file management
    
    /**
    Method that starts data retrival, sends app and json info to server to see if json needs to be updated
    
    */
    func fetchApplicationDataFromServer() {
        let url = "/adapters/demoAdapter/updateCheck/"
        
        let manHelper = ManagerHelper(URLString: url, delegate: self)
        manHelper.addProcedureParams("['\(appVersionNumber)', \(jsonVersionNumber)]")

        manHelper.getResource()
    }
    
    /**
    Wipes out Core Data and reloads with json file.  This insures a clean setup for demo purposes
    
    */
    func saveJsonFileToCoreData() {
        clearAllEntriesFromCoreData()
        
        guard let filePath = NSBundle.mainBundle().pathForResource("OfflineData", ofType: "json") else {
            return
        }
        
        if let jsonObject = loadDataFromJsonFile(filePath) {
            parseJsonObjectIntoCoreData(jsonObject)
        }
        fetchApplicationDataFromServer()
    }
    
    func loadDataFromJsonFile(filePath: String) -> [String: AnyObject]? {
        let data = NSData(contentsOfFile: filePath)
        if let data = data {
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! [String: AnyObject]
                return jsonData
            }
            catch {
                MQALogger.log("Error loading data from Json file: \(error)", withLevel: MQALogLevelError)
                print("Error loading data from Json file: \(error)")
            }
            
        }
        return nil
    }
    
    /**
    Method that updates saved json file with new json data
    
    */
    private func saveDataToJsonFile(jsonData: [String: AnyObject]) {
        guard let filePath = NSBundle.mainBundle().pathForResource("OfflineData", ofType: "json") else {
            return
        }
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(jsonData, options: NSJSONWritingOptions.PrettyPrinted)
            data.writeToFile(filePath, atomically: true)
        }
        catch {
            MQALogger.log("Error writing Json to file: \(error)", withLevel: MQALogLevelError)
            print("Error writing Json to file: \(error)")
        }
    }
    
    // MARK: - Version number management
    
    private func saveVersionNumber(jsonObject: [String: AnyObject]) {
        guard let vNumber = jsonObject["revision"] as? Int else {
            return
        }
        jsonVersionNumber = vNumber
        NSUserDefaults.standardUserDefaults().setValue(jsonVersionNumber, forKey: "jsonVersionNumber")
    }
    
    private func isNewVersion(jsonObject: [String: AnyObject]) -> Bool {
        return !(jsonObject["isUpToDate"] as! Bool)
    }    

    // MARK: - Create methods for managed objects
    
    func createInvitation(timeToMeet: NSDate, location: POI, recipients: [User], from: Int = UserDataManager.sharedInstance.currentUser.id) {
        guard let managedInvitation = createManagedObject("Invitation") else {
            return
        }
        let fromManagedUser = fetchFromCoreData("User", id: from)
        
        // Assume ids are serial
        let count = fetchAllFromCoreData("Invitation").count
        managedInvitation.setValue(count, forKey: "id")
        managedInvitation.setValue(NSDate(), forKey: "timestamp_sent")
        managedInvitation.setValue(timeToMeet, forKey: "timestamp_to_meet")
        managedInvitation.setValue(fetchFromCoreData("POI", id: location.id), forKey: "location")
        // extract ids of recipents for query of core data
        let recipientIds = recipients.map({$0.id})
        managedInvitation.setValue(Set<NSManagedObject>(fetchFromCoreData("User", ids: recipientIds)), forKey: "recipients")
        managedInvitation.setValue(fromManagedUser, forKey: "sender")
        
        saveToCoreData()
        
        let currentUser = UserDataManager.sharedInstance.currentUser
        if from == currentUser.id {
            UserDataManager.sharedInstance.currentUser.invitationsSent.append(Invitation(managedInvitation: managedInvitation))
        }
        else {
            // if the invite is not sent from the current user, assume current user is a recipient and add to cached user object
            UserDataManager.sharedInstance.currentUser.invitationsRecieved.append(Invitation(managedInvitation: managedInvitation))
        }
    }
    
    func createFavoritedPOI(toFavorite: POI) {
        guard let managedFavoritedPOI = createManagedObject("FavoritedPOI") else {
            return
        }
        // assume current user is favoriting the poi
        let currentUser = UserDataManager.sharedInstance.currentUser
        let currentManagedUser = fetchFromCoreData("User", id: currentUser.id)
        
        // Assume ids are serial
        let count = fetchAllFromCoreData("Invitation").count
        managedFavoritedPOI.setValue(count, forKey: "id")
        managedFavoritedPOI.setValue(false, forKey: "complete")
        let managedPOI = fetchFromCoreData("POI", id: toFavorite.id)
        managedFavoritedPOI.setValue(managedPOI, forKey: "poi_favorited")
        managedFavoritedPOI.setValue(currentManagedUser, forKeyPath: "favorited_by")
        
        saveToCoreData()
        
        currentUser.favorites.append(FavoritedPOI(managedFavoritedPOI: managedFavoritedPOI))
    }
    
    func createNotificationFromInvite(invitation: Invitation) -> Notification? {
        guard let managedNotification = createManagedObject("Notification") else {
            return nil
        }
        
        let count = fetchAllFromCoreData("Notification").count
        managedNotification.setValue(count, forKey: "id")
        managedNotification.setValue(invitation.location.descriptionDetail, forKey: "message")
        managedNotification.setValue(false, forKey: "unread")
        managedNotification.setValue("invitation", forKey: "type")
        managedNotification.setValue(invitation.timestampSent, forKey: "timestamp")
     
        // Find the User that sent this invitation
        UserDataManager.sharedInstance.getHostForInvitation(invitation.id) { (user: User?) in
            let invitationText = NSLocalizedString(" Has Sent You An Invitation", comment: "")
            var title = ""
            if let user = user {
                title = user.name + invitationText
            }
            managedNotification.setValue(title, forKey: "title")
        }

        // Set inverse relationship for new notification
        var userSet = Set<NSManagedObject>()
        userSet.insert(fetchFromCoreData("User", id: UserDataManager.sharedInstance.currentUser.id)!)
        managedNotification.setValue(userSet, forKey: "user")
        
        saveToCoreData()
        
        return Notification(managedNotification: managedNotification)
    }
    
    // MARK: - Save From Objects to CoreData
    
    func saveNotification(notification: Notification) {
        let managedNotification = fetchFromCoreData("Notification", id: notification.id)
        managedNotification?.setValue(notification.unread, forKey: "unread")
        saveToCoreData()
    }
    
    // MARK: - Remove From CoreData
    
    func clearAllEntriesFromCoreData() {
        var fetchArray = [NSFetchRequest]()
        fetchArray.append(NSFetchRequest(entityName: "Type"))
        fetchArray.append(NSFetchRequest(entityName: "Detail"))
        fetchArray.append(NSFetchRequest(entityName: "Notification"))
        fetchArray.append(NSFetchRequest(entityName: "ChallengeTask"))
        fetchArray.append(NSFetchRequest(entityName: "Challenge"))
        fetchArray.append(NSFetchRequest(entityName: "User"))
        fetchArray.append(NSFetchRequest(entityName: "POI"))
        fetchArray.append(NSFetchRequest(entityName: "FavoritedPOI"))
        fetchArray.append(NSFetchRequest(entityName: "Invitation"))
        fetchArray.append(NSFetchRequest(entityName: "Group"))
        fetchArray.append(NSFetchRequest(entityName: "Ad"))
        for fetchRequest in fetchArray {
            do {
                let entries = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
                for entry in entries! {
                    managedContext.deleteObject(entry)
                }
            } catch let error as NSError {
                MQALogger.log("Error clearing core data entries: \(error)", withLevel: MQALogLevelError)
                print("Error clearing core data entries: \(error)")
                
            }
        }
        saveToCoreData()
    }
    
    func removeFavoritedPOI(toRemove: POI) {
        let currentUser = UserDataManager.sharedInstance.currentUser
        if let favoritedPOIIndex = currentUser.favorites.indexOf({$0.favoritedPOI.id == toRemove.id}) {
            let favoritedPOI = currentUser.favorites[favoritedPOIIndex]
            let managedFavoritedPOI = fetchFromCoreData("FavoritedPOI", id: favoritedPOI.id)
            managedContext.deleteObject(managedFavoritedPOI!)
            currentUser.favorites.removeAtIndex(favoritedPOIIndex)
            
            saveToCoreData()
        }
    }
    
    // MARK: - Utility Functions
    
    func createManagedObject(objectName: String) -> NSManagedObject? {
        guard let entity = NSEntityDescription.entityForName(objectName, inManagedObjectContext: managedContext) else {
            MQALogger.log("Error in CoreData creating managed object", withLevel: MQALogLevelError)
            print("Error in CoreData creating managed object")
            
            return nil
        }
        return NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedContext)
    }
    
    func saveToCoreData() {
        do {
            try managedContext.save()
        }
        catch {
            MQALogger.log("Error creating managed object: \(error)", withLevel: MQALogLevelError)
            print("Error creating managed object: \(error)")
        }
    }
    
    /**
    Convenience method that queries a selected fetch for an id
    
    */
    func fetchFromCoreData(entity: String, id: Int) -> NSManagedObject? {
        let predicate = NSPredicate(format: "id = %@", String(id))
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
            return fetchResults.first as? NSManagedObject
        }
        catch {
            MQALogger.log("Error fetching from Core Data: \(error)", withLevel: MQALogLevelError)
            print("Error fetching from Core Data: \(error)")
            return nil
        }
    }
    
    /**
    Convenience method that calls fetchFromCoreData for each id given
    
    */
    func fetchFromCoreData(entity: String, ids: [Int]) -> [NSManagedObject] {
        var fetchResults = [NSManagedObject]()
        for id in ids {
            if let fetchResult = fetchFromCoreData(entity, id: id) {
                fetchResults.append(fetchResult)
            }
        }
        return fetchResults
    }
    
    /**
    Convenience method that fetches all of the given entity
    
    */
    func fetchAllFromCoreData(entity: String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: entity)
        do {
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
            if let fetchResults = fetchResults as? [NSManagedObject] {
                return fetchResults
            }
            else {
                return [NSManagedObject]()
            }
        }
        catch {
            MQALogger.log("Error fetching all Core Data entries: \(error)", withLevel: MQALogLevelError)
            print("Error fetching all Core Data entries: \(error)")
            return [NSManagedObject]()
        }
    }
    
}

// MARK: - Helper Delegate methods

extension ApplicationDataManager: HelperDelegate {
    /**
    Method to send user data from a WLResponse if the resource request is successful
    
    :param: response WLResponse containing data
    */
    func resourceSuccess(response: WLResponse!) {
        guard let response = response.getResponseJson() as? [String : AnyObject], let data = response["data"] as? [String: AnyObject] else {
            return
        }
        
        if(isNewVersion(data)) {
            if let blob = data["blob"] as? [String : AnyObject] {
                saveDataToJsonFile(blob)
                saveVersionNumber(blob)
            }
        }
    }
    
    /**
    Method to send error message if the resource request fails
    
    :param: error error message for resource request failure
    */
    func resourceFailure(error: String!) {
        MQALogger.log("Failure grabbing ApplicationDataManager resource \(error)", withLevel: MQALogLevelError)
        print("Failure grabbing ApplicationDataManager resource \(error)")
    }
    
}