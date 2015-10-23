/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import XCTest
@testable import Venue
import Foundation

/// Class to build necessary compnents for unit tests
class MockTest {
    
    /**
    Method to initialize in-memory Core Data stack
    */
    class func initializeData() {
        let app = ApplicationDataManager.sharedInstance
        app.clearAllEntriesFromCoreData()
        guard let filePath = NSBundle.mainBundle().pathForResource("OfflineData", ofType: "json") else {
            XCTFail("Test data json not found")
            return
        }
        
        let jsonObject = app.loadDataFromJsonFile(filePath)
        XCTAssertNotNil(jsonObject)
        app.parseJsonObjectIntoCoreData(jsonObject!)
    }
    
}