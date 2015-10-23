/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import XCTest

class VenueAlertTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        let app = XCUIApplication()

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        NSThread.sleepForTimeInterval(4)
        // Dismiss and select MQA user if prompted
        if(app.tables["Users List"].exists){
            app.swipeUp()
            app.tables["Users List"].staticTexts["Milbuild"].tap()
        }
        if(app.pageIndicators["page 1 of 5"].exists){
            app.buttons["Skip Tutorial"].tap()
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
        selects the invite and the alerts sections and calls unreadHelper()
    */
    func testUnreadAlerts(){
        
        let app = XCUIApplication()

        let inboxButton = app.tabBars.buttons["Inbox"]
        expectData(inboxButton)
        inboxButton.tap()
        
        let tablesQuery = app.tables
        app.swipeUp()
        app.swipeDown()
        
        app.buttons["All Notifications"].tap()
        
        let invitationsStaticText = tablesQuery.staticTexts["Invitations"]
        invitationsStaticText.tap()
        
        let invitationCount = tablesQuery.cells.count
        
        //mark unread invitations as unread and verify unread mark
        unreadHelper(invitationCount)
        
        app.buttons["Invitations"].tap()
        tablesQuery.staticTexts["Alerts"].tap()
        let alertCount = tablesQuery.cells.count
        //mark unread invitations as unread and verify unread mark
        unreadHelper(alertCount)

    }
    
    /**
        goes through all the notifications, taps on the unread ones and
        verifies that they are marked read
    */
    func unreadHelper(cellCount: UInt){
        let app = XCUIApplication()
        var i: UInt = 0
        var readNotif: Bool
        for i; i<cellCount; ++i {
            let notification =  app.tables.elementBoundByIndex(1).childrenMatchingType(.Cell).elementBoundByIndex(i)
            readNotif = notification.images["unreadMark"].exists
            if(readNotif){
                notification.tap()
                app.navigationBars["Notification Details"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
                readNotif = notification.images["unreadMark"].exists
                print(readNotif)
                XCTAssertFalse(readNotif)
            }
        }
    }
    
    /**
        gets counts for each sorted alerts section and verifies sum
    */
    func testSortedAlerts(){
        
        let app = XCUIApplication()
        let inboxButton = app.tabBars.buttons["Inbox"]
        expectData(inboxButton)
        inboxButton.tap()
        
        let tablesQuery = app.tables
                
        app.swipeUp()
        app.swipeDown()
        //get count of all notifications
        let allCount = app.tables.elementBoundByIndex(1).cells.count
        
        app.buttons["All Notifications"].tap()
        tablesQuery.staticTexts["Invitations"].tap()
        
        app.swipeUp()
        app.swipeDown()
        //get count of all invitations
        let inviteCount: UInt = app.tables.elementBoundByIndex(1).cells.count
        
        app.buttons["Invitations"].tap()
        tablesQuery.staticTexts["Alerts"].tap()
        
        app.swipeUp()
        app.swipeDown()
        //get count of all alerts
        let alertCount = app.tables.elementBoundByIndex(1).cells.count
        
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.buttons["Alerts"].tap()
        
        //go back to All Notifications
        tablesQuery.staticTexts["All Notifications"].tap()
        
        //Assert counts add up
        XCTAssertEqual(allCount, inviteCount + alertCount)
    }
    
    /**
        select each alert and compare alert content with alert details,
        verify details match
    */
    func testAlertDetails(){
        let app = XCUIApplication()
        
        let inboxButton = app.tabBars.buttons["Inbox"]
        expectData(inboxButton)
        inboxButton.tap()
        
        let tablesQuery = app.tables
        app.buttons["All Notifications"].tap()
        
        let invitationsStaticText = tablesQuery.staticTexts["Invitations"]
        invitationsStaticText.tap()
        
        let invitationCount = tablesQuery.cells.matchingIdentifier("notificationItem").count
        
        //verify all invitation details and accept if not yet accepted
        for var i: UInt = 0; i<invitationCount; ++i {
            let notification =  app.tables.elementBoundByIndex(1).childrenMatchingType(.Cell).elementBoundByIndex(i)
            let alertDetail = notification.label
            notification.tap()
            let alertTitle = app.staticTexts["alertDetailTitle"].label
            //verify alert title is in alert details
            XCTAssertNotNil(alertDetail.rangeOfString(alertTitle))
            if(app.buttons["Accept Invitation"].exists){
                app.buttons["Accept Invitation"].tap()
                //verify notification banner came down after invite accept
                XCTAssertTrue(app.staticTexts["notificationBannerLabel"].exists)
                
                let attraction = app.scrollViews.otherElements.staticTexts["attractionName"]
                let attractionName = attraction.label
                    attraction.tap()
                
                XCTAssertTrue(app.scrollViews.otherElements.containingType(.StaticText, identifier:attractionName).element.exists)
                NSThread.sleepForTimeInterval(4)
                app.navigationBars.buttons["back"].tap()
            }
            app.navigationBars["Notification Details"].buttons["back"].tap()
        }
        
        app.buttons["Invitations"].tap()
        tablesQuery.staticTexts["Alerts"].tap()
        let alertCount = tablesQuery.cells.matchingIdentifier("notificationItem").count
        //verify all alert details
        for var j: UInt = 0; j<alertCount; ++j{
            if(j == 5){
                app.swipeUp()
            }
            let notification =  app.tables.elementBoundByIndex(1).childrenMatchingType(.Cell).elementBoundByIndex(j)
            let alertDetail = notification.label
            notification.tap()
            let alertTitle = app.staticTexts["alertDetailTitle"].label
            XCTAssertNotNil(alertDetail.rangeOfString(alertTitle))
            app.navigationBars["Notification Details"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        }
    }
}
