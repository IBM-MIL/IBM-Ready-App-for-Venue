/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import XCTest

class VenueHomeUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        NSThread.sleepForTimeInterval(4)
        let app = XCUIApplication()
        if(app.pageIndicators["page 1 of 5"].exists){
            app.images["onboarding_2"].swipeLeft()
            app.images["onboarding_5"].swipeLeft()
            app.images["onboarding_4"].swipeLeft()
            app.images["onboarding_3"].swipeLeft()
            app.buttons["Get Started"].tap()
        }
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
    provides async waiting to make sure the UI components needed
    are on screen when necessary
    */
    func expectData(obj: NSObject){
        let exists = NSPredicate(format: "exists == 1")
        expectationForPredicate(exists, evaluatedWithObject: obj, handler: nil)
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    /**
        Generates notifications from the info button and verify that a notification was sent
    */
    func testGenerateNotif() {
        let app = XCUIApplication()
        
        let moreInfoButton = app.buttons["More Info"]
        expectData(moreInfoButton)
        let tablesQuery = app.tables
        
        moreInfoButton.tap()
        tablesQuery.staticTexts["Context-Driven Offer"].tap()
        XCTAssertTrue(app.staticTexts["notificationBannerLabel"].exists)
        NSThread.sleepForTimeInterval(4)
        
        moreInfoButton.tap()
        tablesQuery.staticTexts["Inclement Weather Alert"].tap()
        XCTAssertTrue(app.staticTexts["notificationBannerLabel"].exists)
        NSThread.sleepForTimeInterval(4)
        
        moreInfoButton.tap()
        tablesQuery.staticTexts["Queue Wait-Time Alert"].tap()
        XCTAssertTrue(app.staticTexts["notificationBannerLabel"].exists)
        NSThread.sleepForTimeInterval(4)
        
        moreInfoButton.tap()
        tablesQuery.staticTexts["Receive an Invitation"].tap()
        XCTAssertTrue(app.staticTexts["notificationBannerLabel"].exists)
        NSThread.sleepForTimeInterval(4)
        
        moreInfoButton.tap()
        tablesQuery.staticTexts["Planned Event Reminder"].tap()
        XCTAssertTrue(app.staticTexts["notificationBannerLabel"].exists)
        NSThread.sleepForTimeInterval(4)
        
        moreInfoButton.tap()
        tablesQuery.staticTexts["Gamification Badge Earned"].tap()
        XCTAssertTrue(app.staticTexts["notificationBannerLabel"].exists)
    }
    
    /**
        Verify Home screen tabs transition correctly
    */
    func testHomeSwipes(){
        
        let app = XCUIApplication()
        
        let nearMeButton = app.buttons["Near Me"]
        expectData(nearMeButton)
        nearMeButton.tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Brick's BBQ"].swipeUp()
        tablesQuery.cells.containingType(.StaticText, identifier:"Pete's Pretzels").childrenMatchingType(.StaticText).matchingIdentifier("attractionName").elementBoundByIndex(0).swipeUp()
        nearMeButton.tap()
        
        //verify transition to the Map screen
        app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(app.buttons["Vortex Map Filter"].exists)
        
        //verify transition to the People screen
        app.tabBars.buttons["People"].tap()
        XCTAssertTrue(app.staticTexts["Your Group Contacts"].exists)
        
        //verify transition to the Challenges screen
        app.tabBars.buttons["Challenges"].tap()
        XCTAssertTrue(app.buttons["Badges"].exists)
        
        //verify transition to the Inbox screen
        app.tabBars.buttons["Inbox"].tap()
        XCTAssertTrue(app.buttons["All Notifications"].exists)
    }
    
    /**
        Verify POI details match the POI title
        Verify adding/removing from favorites by clicking the star icon in POI detail
    */
    func testPOIDetails(){
        let app = XCUIApplication()
        
        let nearMeButton = app.buttons["Near Me"]
        expectData(nearMeButton)
        nearMeButton.tap()
        
        var i: UInt = 0
        let poiList = app.tables.elementBoundByIndex(0).cells
        for i; i<poiList.count; ++i{
            let poiName = poiList.staticTexts.elementBoundByIndex(i).label
            if(poiList.staticTexts.elementBoundByIndex(i).identifier == "attractionName"){
                poiList.staticTexts.elementBoundByIndex(i).tap()
                
                //verify detail name is same
                XCTAssertNotNil(app.staticTexts[poiName])
                let venueNavigationBar = app.navigationBars["Venue.PlaceDetailView"]
                if(venueNavigationBar.buttons["star"].exists){
                    venueNavigationBar.buttons["star"].tap()
                    XCTAssertTrue(app.staticTexts["notificationBannerLabel"].exists)
                }
                else if(venueNavigationBar.buttons["star filled"].exists){
                    venueNavigationBar.buttons["star filled"].tap()
                    XCTAssertTrue(app.staticTexts["notificationBannerLabel"].exists)
                }
                NSThread.sleepForTimeInterval(4)
                if(venueNavigationBar.exists){
                    venueNavigationBar.buttons["back"].tap()
                }
                if(i == 7){
                    poiList.elementBoundByIndex(0).swipeUp()
                    i = i + 2
                }
                if(i == 19){
                    poiList.elementBoundByIndex(9).swipeUp()
                    i = i + 5
                }
                if(i == 33){
                    app.swipeUp()
                    i = i + 3
                }
            }
        }
    }
}
