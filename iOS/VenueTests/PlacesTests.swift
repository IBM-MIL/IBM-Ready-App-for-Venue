/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import XCTest
@testable import Venue

class PlacesTests: XCTestCase {
    
    var viewModel: PlacesViewModel!
    
    override func setUp() {
        super.setUp()
        MockTest.initializeData()
        viewModel = PlacesViewModel()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /**
    Tests that the mapImageName in the view model exists
    */
    func testPlacesViewModel() {
        
        XCTAssertNotNil(viewModel.mapImageName, "Map Image Name is nil and it should be created in the init() method")
    }
    
    /**
    Tests that the getCurrentUser() object returns a User object
    */
    func testCurrentUser() {
        
        XCTAssertNotNil(viewModel.getCurrentUser(), "getCurrentUser() should return a User object but it is returning nil")
    }
    
    /**
    Tests the getPOIs() function. Check that there are more than 0 POIs
    */
    func testPlacesPOIs() {
        
        viewModel.getPOIs() { poiDict in
            XCTAssertGreaterThan(poiDict.count, 0, "There should be more than 0 Points of Interest")
        }
    }
    
    /**
    Tests the getMyPeople() function. Test that number of people is > 0, and that the current user is removed from 
    the dictionary of people
    */
    func testPlacesMyPeople() {
        
        // Get All People from core data
        let appDataManager = ApplicationDataManager.sharedInstance
        let myPeople = appDataManager.loadUsersFromCoreData()
        
        viewModel.getMyPeople() { myPeopleDict in
            XCTAssertGreaterThan(myPeopleDict.count, 0, "There should be more than 0 People in the group")
            XCTAssertLessThan(myPeopleDict.count, myPeople.count, "There should be 1 less person in the My People group then all the Users")
        }
    }
}
