/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import XCTest

class VenueChallengesUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        
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
        // Dismiss tutorial screen if prompted
        if(app.images["onboarding_2"].exists){
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
    
    /*
        Automated UI test simulating the user flow going to the leaderboard tab
        Clicking on a user on the leaderboard goes to the detailed page
        Test verifies that the selected user and point count actually matches
        to the information on the details page
    */

    func testLeaderBoardFlow(){
        
        let app = XCUIApplication()
        let challengesButton = app.tabBars.buttons["Challenges"]
        expectData(challengesButton)
        challengesButton.tap()
        
        let leaderboardButton = app.buttons["Leaderboard"]
        leaderboardButton.tap()
        var index: UInt = 0
        let count = app.tables.elementBoundByIndex(0).cells.count
        XCTAssertEqual(count, 12)
        
        leaderboardLoop: for index; index<count; ++index {
            let user = app.tables.childrenMatchingType(.Cell).elementBoundByIndex(index).staticTexts["username"]
            let username = user.label

            let points = app.tables.childrenMatchingType(.Cell).elementBoundByIndex(index).staticTexts["userPoints"].label
            if(index == 8){
                app.swipeUp()
            }
            user.tap()
            
            let userNameDetail = app.staticTexts["userNameDetail"]
            let pointsDetail = app.staticTexts["userPointsDetail"]
    
            XCTAssertTrue(userNameDetail.exists)
            XCTAssertTrue(pointsDetail.exists)
            
            //Verify that player name and point count are correct
            XCTAssertTrue(userNameDetail.label == username)
            XCTAssertTrue(pointsDetail.label == points + " PTS")
            
            let userBadgeCells = app.collectionViews.childrenMatchingType(.Cell)
            for var indexJ:UInt = 0; indexJ<userBadgeCells.count; ++indexJ{
                if(indexJ == 4)
                {
                    app.swipeUp()
                }
                let badge = app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(indexJ).staticTexts["funAwardLabel"]
                if(points == "0"){
                    app.buttons["<"].tap()
                    break leaderboardLoop
                }
                let badgeLabel = badge.label
                badge.tap()
                let badgeName = app.navigationBars[badgeLabel].staticTexts[badgeLabel].label

                //confirm badge name
                XCTAssertEqual(badgeLabel, badgeName)
                
                app.navigationBars[badgeLabel].buttons["back"].tap()
            }
            
            if(app.navigationBars["Player's Score"].exists){
                app.navigationBars["Player's Score"].buttons["back"].tap()
            }
            else{
                app.navigationBars["Your Score"].buttons["back"].tap()
            }
        }
    }
    
    /**
        Verify badge detail for a person on the leaderboard
    */
    func testLeaderBoardAwardDetail(){
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        
        let challengesButton = tabBarsQuery.buttons["Challenges"]
        expectData(challengesButton)
        challengesButton.tap()
        
        app.buttons["Leaderboard"].tap()
        
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0).staticTexts["username"].tap()

        let funAward = app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(0).staticTexts["funAwardLabel"]
        let funAwardLabel = funAward.label
        funAward.tap()
        let badgeDetail = app.navigationBars[funAwardLabel].staticTexts[funAwardLabel].label
        //confirm badge name
        XCTAssertTrue(app.navigationBars[funAwardLabel].staticTexts[funAwardLabel].exists)
        XCTAssertEqual(funAwardLabel, badgeDetail)
        
        app.navigationBars[funAwardLabel].buttons["back"].tap()
    }
    
    /**
        Verify badge detail for all the badges in the Badge screen
    */
    func testBadgeFlow(){
        let app = XCUIApplication()
        let challengesButton = app.tabBars.buttons["Challenges"]
        expectData(challengesButton)
        challengesButton.tap()
        app.buttons["Badges"].tap()
        app.swipeUp()
        app.swipeUp()
        let badgeCount = app.collectionViews.cells.count
        var index: UInt = badgeCount - 1
        //swipe all the way to the bottom
        for index; index>0; --index {
            let lastBadge = app.collectionViews.cells.elementBoundByIndex(index).staticTexts["badgeTitle"]
            let lastBadgeLabel = lastBadge.label
            lastBadge.tap()
            let badgeDetail = app.navigationBars[lastBadgeLabel].staticTexts[lastBadgeLabel].label
            //confirm badge name
            XCTAssertTrue(app.navigationBars[lastBadgeLabel].staticTexts[lastBadgeLabel].exists)
            XCTAssertEqual(lastBadgeLabel, badgeDetail)
            
            app.navigationBars[lastBadgeLabel].buttons["back"].tap()
            
            if(index == 4){
                app.collectionViews.cells.elementBoundByIndex(index+3).swipeDown()
            }
        }
    }
    
}
