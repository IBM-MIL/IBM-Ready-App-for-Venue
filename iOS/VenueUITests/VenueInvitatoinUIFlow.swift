/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import XCTest

class VenueInvitatoinUIFlow: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        let app = XCUIApplication()

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        NSThread.sleepForTimeInterval(5)
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
        Verifies sending an invite by selecting a POI from the 'My List' section
    */
    func testInviteMyList() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        expectData(tablesQuery.elementBoundByIndex(0))
        let attraction = tablesQuery.cells.elementBoundByIndex(1).staticTexts["attractionName"]
        let attractionName = attraction.label
        
        attraction.tap()
        
        app.buttons["Invite People"].tap()
        tablesQuery.staticTexts["Tony Ballands"].tap()
        app.swipeUp()

        let checkedCount = getCheckedCount()
        
        let collectionViewsQuery = app.collectionViews
        var avatarCount: Int = getAvatarCount(collectionViewsQuery.images.count)
        
        //verify number of selected people matches avatar numbers
        XCTAssertEqual(avatarCount, checkedCount)
        app.buttons["inviteButton"].tap()
        
        avatarCount = getAvatarCount(collectionViewsQuery.images.count)
        
        //verify number of selected people still matches avatar numbers
        XCTAssertEqual(avatarCount, checkedCount)
        app.buttons["sendInvite"].tap()
        
        //verify the selected attraction was in the invitation
        let invitationText = app.staticTexts["notificationBannerLabel"].label
        XCTAssertNotNil(invitationText.rangeOfString(attractionName))
    }
    
    /**
        A helper function to get count of all the checked userItems
    */
    func getCheckedCount()->Int {
        let tablesQuery = XCUIApplication().tables
        let userItem = tablesQuery.cells.containingType(.Cell, identifier: "userItem")
        var checkedCount = 0
        
        for (var i: UInt = 0; i<=userItem.count-1; ++i){
            if(userItem.elementBoundByIndex(i).images["checkmark"].exists)
            {
                checkedCount++
            }
        }
        return checkedCount
    }
    
    /**
        A helper function to get count of all the avatars that show on the bottom bar
    */
    func getAvatarCount(count : UInt)->Int{
        var avatarCount = 0
        
        let app = XCUIApplication()
        
        for (var i: UInt = 0; i<=count-1; ++i){
            let image = app.collectionViews.images.elementBoundByIndex(i)
            if(image.label == "avatar"){
                avatarCount++
            }
        }
        return avatarCount
    }
    
    /**
        Verifies sending an invite from the 'Near Me' screen
        Verifies search functionality on the people list screen
    */
    func testInviteNearMeSearch() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let nearMeButton = app.buttons["Near Me"]
        expectData(nearMeButton)
        nearMeButton.tap()
        
        tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(0).staticTexts["attractionName"].tap()
        app.buttons["Invite People"].tap()
        
        let searchTextField = app.textFields["Search"]
        searchTextField.tap()
        searchTextField.typeText("c")
        //verify search results
        XCTAssertEqual(tablesQuery.cells.containingType(.Cell, identifier: "userItem").count, 2)
        
        tablesQuery.staticTexts["Alicia Clark"].tap()
        searchTextField.tap()
        app.keys["Delete"].doubleTap()
        app.typeText("\n")
        searchTextField.tap()
        searchTextField.typeText("a")
        //verify search results
        XCTAssertEqual(tablesQuery.cells.containingType(.Cell, identifier: "userItem").count, 4)
                
        app.typeText("\n")
        tablesQuery.staticTexts["Alicia Clark"].tap()
        tablesQuery.staticTexts["Amir Tiwari"].tap()
        app.buttons["inviteButton"].tap()
        
    }
    
    /**
        sends mutiple invites to different POI and verifies that confirmation notification was received 
    */
    func testMultipleInvites(){
        let app = XCUIApplication()
        let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        let element2 = element.childrenMatchingType(.Other).elementBoundByIndex(1)
        
        let tablesQuery = app.tables
        let nearMeButton = app.buttons["Near Me"]
        expectData(nearMeButton)
        nearMeButton.tap()
        
        let attraction = app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).staticTexts["attractionName"]
        let attractionName = attraction.label
        attraction.tap()
        
        let invitePeopleButton = app.buttons["Invite People"]
        invitePeopleButton.tap()
        tablesQuery.staticTexts["Lauren Akers"].tap()
        
        tablesQuery.staticTexts["B"].swipeUp()
        
        tablesQuery.staticTexts["Melvin Hallam"].tap()
        
        let invitebuttonButton = app.buttons["inviteButton"]
        invitebuttonButton.tap()
        
        let sendinviteButton = app.buttons["sendInvite"]
        sendinviteButton.tap()
        let invitationText = app.staticTexts["notificationBannerLabel"].label
        
        //Verify Invite
        XCTAssertNotNil(invitationText.rangeOfString(attractionName))
        NSThread.sleepForTimeInterval(4)

        let backButton = app.navigationBars.buttons["back"]
        backButton.tap()
        
        let attraction2 = tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(2).staticTexts["attractionName"]
        let attraction2Name = attraction2.label
        attraction2.tap()
        
        invitePeopleButton.tap()
        tablesQuery.staticTexts["Tony Ballands"].tap()
        invitebuttonButton.tap()
        sendinviteButton.tap()
        //Verify Invite
        let invitationText2 = app.staticTexts["notificationBannerLabel"].label
        XCTAssertNotNil(invitationText2.rangeOfString(attraction2Name))
        
        NSThread.sleepForTimeInterval(4)
        backButton.tap()
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
                
        let attraction3 = tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(37).staticTexts["attractionName"]
        let attraction3Name = attraction3.label
        attraction3.tap()
        
        invitePeopleButton.tap()
        tablesQuery.staticTexts["Alicia Clark"].tap()
        tablesQuery.staticTexts["B"].swipeUp()
        
        tablesQuery.staticTexts["Dylan Dunham"].tap()
        tablesQuery.staticTexts["Tori Thomas"].tap()
        tablesQuery.staticTexts["Amir Tiwari"].tap()
        element2.tap()
        invitebuttonButton.tap()
        sendinviteButton.tap()
        //Verify Invite
        let invitationText3 = app.staticTexts["notificationBannerLabel"].label
        XCTAssertNotNil(invitationText3.rangeOfString(attraction3Name))
    }
}
