/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import XCTest
@testable import Venue

class DataModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        MockTest.initializeData()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
    Tests the clearAllEntriesFromCoreData method. Check that there are no objects returned from load methods
    */
    func testClearAllEntriesFromCoreData() {
        let app = ApplicationDataManager.sharedInstance
        guard let filePath = NSBundle.mainBundle().pathForResource("OfflineData", ofType: "json") else {
            XCTFail("Test data json not found")
            return
        }
        
        let jsonObject = app.loadDataFromJsonFile(filePath)
        XCTAssertNotNil(jsonObject)
        app.parseJsonObjectIntoCoreData(jsonObject!)
        app.clearAllEntriesFromCoreData()
        
        let users = app.loadUsersFromCoreData()
        XCTAssertEqual(users.count, 0)
        
        let pois = app.loadPOIsFromCoreData()
        XCTAssertEqual(pois.count, 0)
        
        let notifications = app.loadNotificationsFromCoreData()
        XCTAssertEqual(notifications.count, 0)
        
        let invitations = app.loadInvitationsFromCoreData()
        XCTAssertEqual(invitations.count, 0)
        
        let challenges = app.loadChallengesFromCoreData()
        XCTAssertEqual(challenges.count, 0)
        
        let ads = app.loadAdsFromCoreData()
        XCTAssertEqual(ads.count, 0)
        
        let poiTypes = app.loadPoiTypesFromCoreData()
        XCTAssertEqual(poiTypes.count, 0)
    }
    
    /**
    Tests the parseJsonObjectIntoCoreData method. Checks that there is the correct data for properties and relationships is loaded in from the OfflineData json 
    */
    func testParsingJsonObject() {
        let app = ApplicationDataManager.sharedInstance
        app.clearAllEntriesFromCoreData()
        guard let filePath = NSBundle.mainBundle().pathForResource("OfflineData", ofType: "json") else {
            XCTFail("Test data json not found")
            return
        }
        
        let jsonObject = app.loadDataFromJsonFile(filePath)
        XCTAssertNotNil(jsonObject)
        app.parseJsonObjectIntoCoreData(jsonObject!)
        let userArray = app.loadUsersFromCoreData()
        XCTAssertGreaterThan(userArray.count, 0)
        let user0 = userArray[0]
        XCTAssertEqual(user0.id, 2)
        XCTAssertEqual(user0.phoneNumber, "512-555-7890")
        XCTAssertEqual(user0.tasksCompleted.count, 11)
        XCTAssertEqual(user0.challengesCompleted.count, 3)
        
    }
}