/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import XCTest

class VenueMapUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        let app = XCUIApplication()
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        NSThread.sleepForTimeInterval(4)

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
        Verifies that the location of the current user is shown
    */
    func testUserCurrentLocation() {
        let app = XCUIApplication()
        let mapButton = app.tabBars.buttons["Map"]
        expectData(mapButton)
        mapButton.tap()
        XCTAssertNotNil(app.buttons["your location"])
    }
    
    /**
        Verifies the people labels match with bottom detail when tapped
    */
    func testPeopleLocation(){
        let app = XCUIApplication()
        let mapButton = app.tabBars.buttons["Map"]
        expectData(mapButton)
        mapButton.tap()
        var peopleCount: Int = 0
        
        app.scrollViews.containingType(.Button, identifier:"Vortex Map Pin Dining").element.swipeRight()

        app.buttons["Andrew Jacobs"].tap()
        XCTAssertEqual("Andrew Jacobs", app.staticTexts["POIName"].label)
        peopleCount++
        
        app.buttons["Lauren Akers"].tap()
        XCTAssertEqual("Lauren Akers", app.staticTexts["POIName"].label)
        peopleCount++
        
        app.buttons["Tony Ballands"].tap()
        XCTAssertEqual("Tony Ballands", app.staticTexts["POIName"].label)
        peopleCount++
        
        app.buttons["Bart Black"].tap()
        XCTAssertEqual("Bart Black", app.staticTexts["POIName"].label)
        peopleCount++
        
        app.buttons["Alicia Clark"].tap()
        XCTAssertEqual("Alicia Clark", app.staticTexts["POIName"].label)
        app.buttons["Tall Tex"].tap()
        app.buttons["Anaconda"].tap()
        peopleCount++
        
        app.buttons["Security"].tap()
        app.buttons["Melvin Hallam"].tap()
        XCTAssertEqual("Melvin Hallam", app.staticTexts["POIName"].label)
        peopleCount++
        
        app.buttons["Ned Greyson"].tap()
        XCTAssertEqual("Ned Greyson", app.staticTexts["POIName"].label)
        peopleCount++
        
        app.buttons["Dylan Dunham"].tap()
        XCTAssertEqual("Dylan Dunham", app.staticTexts["POIName"].label)
        peopleCount++
        
        app.buttons["Francesca Cortez"].tap()
        XCTAssertEqual("Francesca Cortez", app.staticTexts["POIName"].label)
        app.buttons["Dylan Dunham"].tap()
        app.buttons["Melvin Hallam"].tap()

        peopleCount++
        
        app.buttons["Amir Tiwari"].tap()
        XCTAssertEqual("Amir Tiwari", app.staticTexts["POIName"].label)
        peopleCount++
        
        app.buttons["Tori Thomas"].tap()
        XCTAssertEqual("Tori Thomas", app.staticTexts["POIName"].label)
        peopleCount++
        
        XCTAssertEqual(peopleCount, 11)
        
    }
    
    /**
        Verifies that each POI type corresponds to the actual count
    */
    func testMapPOICounts(){
        let app = XCUIApplication()
        
        let mapButton = app.tabBars.buttons["Map"]
        expectData(mapButton)
        mapButton.tap()
        
        XCTAssertEqual(getRideCount(), 8)
        
        XCTAssertEqual(getDiningCount(), 12)
        
        XCTAssertEqual(getGameCount(), 6)
        
        let lockerCount = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Lockers").count
        XCTAssertEqual(lockerCount, 1)

        let waterRideCount = XCUIApplication().scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin WaterRides").count
        XCTAssertEqual(waterRideCount, 1)
        
        let lostFoundCount = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin LostAndFound").count
        XCTAssertEqual(lostFoundCount, 1)
        
        let guestServicesCount = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin GuestServices").count
        XCTAssertEqual(guestServicesCount, 1)
        
        let firstAidCount = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin FirstAid").count
        XCTAssertEqual(firstAidCount, 1)
        
        let securityCount = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Security").count
        XCTAssertEqual(securityCount, 1)
        
        let entertainmentCount = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Entertainment").count
        XCTAssertEqual(entertainmentCount, 1)
        
        let shopCount = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Shopping").count
        XCTAssertEqual(shopCount, 1)
        
        XCTAssertEqual(getRestroomCount(), 4)
    }
    
    /**
        Helper function to get ride count
    */
    func getRideCount()->UInt{
        let rideCount = XCUIApplication().scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Rides").count
        return rideCount
    }
    /**
        Helper function to get game count
    */
    func getGameCount()->UInt{
        let gameCount = XCUIApplication().scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Games").count
        return gameCount
    }
    
    /**
        Helper function to get dining count
    */
    func getDiningCount()->UInt{
        let getDiningCount = XCUIApplication().scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Dining").count
        return getDiningCount
    }
    
    /**
    Helper function to get restroom count
    */
    func getRestroomCount()->UInt{
        let restroomCount = XCUIApplication().scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Restrooms").count
        return restroomCount
    }

    /**
        verifies the map filter functionality
    */
    func testMapFilter(){
        let app = XCUIApplication()
        
        let mapButton = app.tabBars.buttons["Map"]
        expectData(mapButton)
        mapButton.tap()
        
        app.buttons["Vortex Map Filter"].tap()
        let cellsQuery = app.collectionViews.cells
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Rides").images["filterImage"].tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Dining").images["filterImage"].tap()
        app.buttons["Apply"].tap()
        //verify number of Rides
        //verify that other all filtered pins are shown
        XCTAssertEqual(getRideCount(), 8)
        checkAllRides(app)

        XCTAssertEqual(getDiningCount(), 12)
        checkAllDining()

        app.buttons["Vortex Map Filter"].tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Entertainment").images["filterImage"].tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Water Rides").images["filterImage"].tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Rides").images["filterImage"].tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Dining").images["filterImage"].tap()
        app.buttons["Apply"].tap()
        //verify that all filtered pins are shown
        app.buttons["Anaconda"].tap()
        XCTAssertEqual(app.buttons["Anaconda"].identifier, app.staticTexts["POIName"].label)
        app.swipeRight()
        app.buttons["Ye Olde Brickland Theater"].tap()
        XCTAssertEqual(app.buttons["Ye Olde Brickland Theater"].identifier, app.staticTexts["POIName"].label)
        
        app.buttons["Vortex Map Filter"].tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Clear Filters").images["filterImage"].tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"People").images["filterImage"].tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Security").images["filterImage"].tap()

        app.buttons["Apply"].tap()
        
        //verify that all filtered pins are shown
        testPeopleLocation()
    }
    
    /**
        Helper function to verify ride and dinning pin details
    */
    func testPOIRidesAndDinning(){
        let app = XCUIApplication()
        
        let mapButton = app.tabBars.buttons["Map"]
        expectData(mapButton)
        mapButton.tap()
        checkAllRides(app)
        
        checkAllDining()
    }
    
    /**
        Helper function to verify ride details on the map
    */
    func checkAllRides(app: XCUIElement){
        //check all the Rides and verify Bottom Bar name
        let rides = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Rides")
        
        for(var index: UInt = 0; index<rides.count; ++index){
            let ride = rides.elementBoundByIndex(index)
            XCTAssertTrue(ride.exists)
            ride.tap()
            XCTAssertEqual(ride.identifier, app.staticTexts["POIName"].label)
            
            switch index{
            case 0:
                app.swipeRight()
            case 1:
                app.buttons["Cup O' Joe 2 Go"].tap()
            case 3:
                app.buttons["Merry Go Round"].tap()
           case 5:
                app.buttons["Pete's Pretzels"].tap()
            case 6:
                app.buttons["Pete's Pretzels"].tap()
                app.buttons["Merry Go Round"].tap()
                app.buttons["Brick Blaster"].tap()
            default:
                print("Other Options")
            }
        }
    }
    
    /**
        Helper function to verify dining details on the map
    */
    func checkAllDining(){
        let app = XCUIApplication()

        //check all the Dining Pins and verify Bottom Bar name
        let dining = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Dining")
        var dinerID: NSString
        for(var index: UInt = 0; index<dining.count; ++index){
            switch index{
            case 0:
                app.swipeDown()
            case 1:
                app.buttons["Cup O' Joe 2 Go"].tap()
            case 4:
                app.buttons["Funnel Cake Fever"].tap()
                app.buttons["Cup O' Joe 2 Go"].tap()
            case 6:
                app.buttons["Cactus Canyon"].tap()
                app.buttons["Tall Tex"].tap()
                app.buttons["Tejas Twister"].tap()
            case 8:
                app.buttons["Pete's Pretzels"].tap()
                app.buttons["Merry Go Round"].tap()
                app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Frosty Freeze").elementBoundByIndex(3).tap()
                app.buttons["Sweets 'N' Treats"].tap()
            case 10:
                app.buttons["Merry Go Round"].tap()
            case 11:
                app.buttons["Tejas Twister"].tap()
            default:
                print("Other Options")
            }
            let diner = dining.elementBoundByIndex(index)
            dinerID = diner.identifier
            XCTAssertTrue(diner.exists)
            dining.elementBoundByIndex(index).tap()
            XCTAssertEqual(dinerID, app.staticTexts["POIName"].label)
        }
    }
    
    /**
        Helper function to verify game pin details
    */
    func testPOIGames(){
        let app = XCUIApplication()
        
        let mapButton = app.tabBars.buttons["Map"]
        expectData(mapButton)
        mapButton.tap()
        //check all the Games and verify Bottom Bar name
        let rides = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Games")
        
        for(var index: UInt = 0; index<rides.count; ++index){
            switch index{
            case 0:
                app.buttons["Anaconda"].tap()
                //check Water Ride category
                XCTAssertEqual(app.buttons["Anaconda"].identifier, app.staticTexts["POIName"].label)
            case 1:
                app.buttons["Anaconda"].tap()
                app.buttons["Tall Tex"].tap()
                app.buttons["Cactus Canyon"].tap()
                app.buttons["Brick Blaster"].tap()
            case 2,5:
                app.swipeLeft()
            case 3:
                app.buttons["Tall Tex"].tap()
            case 4:
                app.buttons["Wonder Wheel"].tap()
            default:
                print("Other Options")
            }
            let ride = rides.elementBoundByIndex(index)
            ride.tap()
            XCTAssertEqual(ride.identifier, app.staticTexts["POIName"].label)
        }
    }
    
    /**
        Helper function to verify pin details in small categories
    */
    func testPOIOther(){
        let app = XCUIApplication()
        
        let mapButton = app.tabBars.buttons["Map"]
        expectData(mapButton)
        mapButton.tap()
        //check all the Games and verify Bottom Bar name
        let pois = app.scrollViews.childrenMatchingType(.Button).matchingIdentifier("Vortex Map Pin Restrooms")
        
        for(var index: UInt = 0; index<pois.count; ++index){
            switch index{
            case 0:
                app.buttons["Tall Tex"].tap()
                app.buttons["Brickland Bazaar"].tap()
                //check Shopping category
                XCTAssertEqual(app.buttons["Brickland Bazaar"].identifier, app.staticTexts["POIName"].label)
            case 1:
                app.swipeLeft()
            case 2:
                app.swipeRight()
            case 3:
                app.buttons["Brick Blaster"].tap()
                app.buttons["First Aid"].tap()
                //check First Aid category
                XCTAssertEqual(app.buttons["First Aid"].identifier, app.staticTexts["POIName"].label)
            default:
                print("Other Options")
            }
            
            let poi = pois.elementBoundByIndex(index)
            poi.tap()
            XCTAssertEqual(poi.identifier, app.staticTexts["POIName"].label)
        }
        //check Guest Services category
        app.buttons["Guest Services"].tap()
        XCTAssertEqual(app.buttons["Guest Services"].identifier, app.staticTexts["POIName"].label)

        //check Lost & Found category
        app.buttons["Lost & Found"].tap()
        XCTAssertEqual(app.buttons["Lost & Found"].identifier, app.staticTexts["POIName"].label)

        //check Security category
        app.buttons["Security"].tap()
        XCTAssertEqual(app.buttons["Security"].identifier, app.staticTexts["POIName"].label)
        
        //check Lockers category
        app.buttons["Lockers"].tap()
        XCTAssertEqual(app.buttons["Lockers"].identifier, app.staticTexts["POIName"].label)
        
        //check Entertainment category
        app.buttons["Wonder Wheel"].tap()
        app.buttons["Ye Olde Brickland Theater"].tap()
        XCTAssertEqual(app.buttons["Ye Olde Brickland Theater"].identifier, app.staticTexts["POIName"].label)
    }
}
