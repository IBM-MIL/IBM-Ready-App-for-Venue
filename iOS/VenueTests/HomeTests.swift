/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import XCTest
@testable import Venue

class HomeTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        MockTest.initializeData()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
    Verifies data was returned from Core Data into view model
    */
    func testHomeViewModel() {
        
        let viewModel = HomeViewModel()
        viewModel.rowsInSection(0) // This method activates reloading of data
        
        XCTAssertGreaterThan(viewModel.poiArray.count, 0)
        XCTAssertGreaterThan(viewModel.userPoiList.count, 0)
        XCTAssertGreaterThan(viewModel.userCompletePoiList.count, 0)
        XCTAssertTrue(viewModel.dataPresent, "There was no data returned")
    }
    
    /**
    Test that wait label changes colors as expected, based on wait time
    */
    func testWaitLabel() {
        
        let label = VenueWaitLabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.textColor = UIColor.whiteColor()
        XCTAssertEqual(label.textColor, UIColor.whiteColor())

        for index in 0...70 {
            label.updateTextColor(index)
            if index < 30 {
                XCTAssertEqual(label.textColor, UIColor.venueLightGreen())
            } else if index >= 30 && index < 60 {
                XCTAssertEqual(label.textColor, UIColor.venueLightOrange())
            } else {
                XCTAssertEqual(label.textColor, UIColor.venueRed())
            }
        }
    }
    
}
