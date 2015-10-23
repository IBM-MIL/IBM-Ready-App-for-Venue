/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import XCTest

class VenuePeopleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
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
        Simulates searching for people in the people screen
    */
    func testPeopleSearch() {
        let app = XCUIApplication()
        let peopleButton = app.tabBars.buttons["People"]
        expectData(peopleButton)
        peopleButton.tap()
        
        let searchTextField = app.textFields["Search"]
        searchTextField.tap()
        searchTextField.typeText("b")
        app.typeText("\n")
        //go through the search results and verify username in the details page
        verifyUserName()
        
        app.buttons["Clear text"].tap()
        //search with leading white space
        searchTextField.typeText("      a")
        app.typeText("\n")
        //go through the search results and verify username in the details page
        verifyUserName()
        
        app.buttons["Clear text"].tap()
        searchTextField.typeText("t")
        app.typeText("\n")
        //go through the search results and verify username in the details page
        verifyUserName()
    }
    
    /**
        taps on each user on the list and verifies that the details match the userItem info
    */
    func verifyUserName(){
        let app = XCUIApplication()
        var index: UInt = 0
        let userItem = app.tables.cells.containingType(.Cell, identifier: "userItem")
        let userCount = userItem.count
        for index; index<userCount; ++index{
            if(index == 5){
                app.swipeUp()
                app.swipeUp()
                app.staticTexts["Amir Tiwari"].swipeDown()
            }
            if(index == 6){
                app.staticTexts["Lauren Akers"].swipeUp()
                break
            }
            let username = userItem.elementBoundByIndex(index).label
            userItem.elementBoundByIndex(index).tap()
            XCTAssertNotNil(username.rangeOfString(app.staticTexts["userDetailName"].label))
            app.navigationBars["Person Details"].buttons["back"].tap()
        }
    }
    
    /**
        verifies that the details match the userItem info
    */
    func testPeopleDetail(){
        let app = XCUIApplication()
        let peopleButton = app.tabBars.buttons["People"]
        expectData(peopleButton)
        peopleButton.tap()
        
        //Go Through all the user items and verify username on the details page
        verifyUserName()
    }
}
