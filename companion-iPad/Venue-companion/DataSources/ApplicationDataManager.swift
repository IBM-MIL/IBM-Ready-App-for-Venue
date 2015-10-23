/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import UIKit
import CoreData

class ApplicationDataManager: NSObject {
    
    static let sharedInstance = ApplicationDataManager()
    
    var currentUser: User?
    
    var users: [User] = []
    var challenges: [Challenge] = []
    var tasks: [ChallengeTask] = []
    var pois: [POI] = []
    var types: [POIType] = []
    
    var globalLeaderboard: [String: Int] = [:]
    
    func fetchData() {
        if let filePath = NSBundle.mainBundle().pathForResource("DemoData", ofType: "json") {
            if let data = loadDataFromJsonFile(filePath) {
                getPOIsFromData(data)
                getChallengesFromData(data)
                getUsersFromData(data)
                getLeaderboardFromData(data)
            }
        } else {
            print("Invalid file path.")
        }
    }
    
    func loadDataFromJsonFile(filePath: String) -> [String: AnyObject]? {
        if let data = NSData(contentsOfFile: filePath) {
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! [String: AnyObject]
                return jsonData
            } catch {
                print("Invalid data in json file. \(error)")
            }
        } else {
            print("Invalid data in json file.")
        }
        return nil
    }
    
    func setCurrentUser() {
        currentUser = self.users[0]
    }
    
    func getUsersFromData(data: [String: AnyObject]) {
        MQALogger.log("Getting Users.")
        if let users = data["users"] as? [[String: AnyObject]] {
            for user  in users {
                let userObject = User(dictionary: user)
                userObject.currentLocationX -= 50
                userObject.currentLocationY -= 105
                self.users.append(userObject)
                globalLeaderboard[userObject.name] = userObject.score
            }
            print("User count: \(self.users.count)")
        }
        
    }
    
    func getPOIsFromData(data: [String: AnyObject]) {
        MQALogger.log("Getting POI Types.")
        if let types = data["types"] as? [[String: AnyObject]] {
            for type  in types {
                self.types.append(POIType(dictionary: type))
            }
            print("Type count: \(self.types.count)")
        }
        
        MQALogger.log("Getting POIs.")
        if let pois = data["POIs"] as? [[String: AnyObject]] {
            for poi  in pois {
                let poi = POI(dictionary: poi)
                poi.coordinateX -= 65
                poi.coordinateY -= 170
                self.pois.append(poi)
            }
            print("POI count: \(self.pois.count)")
        }
        
    }
    
    func getChallengesFromData(data: [String: AnyObject]) {
        MQALogger.log("Getting Challenge Tasks.")
        if let tasks = data["challengeTasks"] as? [[String: AnyObject]] {
            for task  in tasks {
                self.tasks.append(ChallengeTask(dictionary: task))
            }
            print("Task count: \(self.tasks.count)")
        }
        
        MQALogger.log("Getting Challenges.")
        if let challenges = data["challenges"] as? [[String: AnyObject]] {
            for challenge  in challenges {
                self.challenges.append(Challenge(dictionary: challenge))
            }
            print("Challenges count: \(self.challenges.count)")
        }
        
    }
    
    func getLeaderboardFromData(data: [String: AnyObject]) {
        MQALogger.log("Getting Leaderboard.")
        if let leaderboard = data["leaderboard"] as? [[String: AnyObject]] {
            for user  in leaderboard {
                let userObject = LeaderboardUser(dictionary: user)
                globalLeaderboard[userObject.name] = userObject.score
            }
            print(self.globalLeaderboard)
        }
        
    }

}
