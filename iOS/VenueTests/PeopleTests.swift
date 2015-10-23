/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import XCTest
@testable import Venue

class PeopleTests: XCTestCase {
    
    var peopleViewModel: PeopleListViewModel!
    
    override func setUp() {
        super.setUp()
        MockTest.initializeData()
        peopleViewModel = PeopleListViewModel()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /**
    Tests the parseUsersIntoSections method in the PeopleListViewModel. Checks that the users (as supplied by OfflineData.json) have been parsed into the right sections
    */
    func testNameSections() {

        XCTAssert(peopleViewModel.displayedUserSections.count == 8, "Number of last name sections does not match number of unique last name initals")
        XCTAssert(peopleViewModel.displayedUserSections[0].key == "A", "'A' is not the first initial")
        XCTAssert(peopleViewModel.displayedUserSections[0].users.count == 1, "Number of users with last name starting with 'A' does not match")
        XCTAssert(peopleViewModel.displayedUserSections[7].key == "T", "'T' is not the eigth initial")
        XCTAssert(peopleViewModel.displayedUserSections[7].users[0].name == "Tori Thomas", "Wrong name for first 'T'")
    }
    
    /**
    Tests the filterPeople method in the PeopleListViewModel. Checks that multiple queries return the correct results
    */
    func testFiltering() {

        peopleViewModel.filterPeople("a")
        var count = 0
        for section in peopleViewModel.displayedUserSections {
            count += section.users.count
        }
        XCTAssert(count == 4, "Wrong number of users filtered")
        
        peopleViewModel.filterPeople(" a ")
        var count2 = 0
        for section in peopleViewModel.displayedUserSections {
            count2 += section.users.count
        }
        XCTAssert(count == count2, "white space is not properally stripped in search")
        
        peopleViewModel.filterPeople("amir tiwari")
        if peopleViewModel.displayedUserSections.count > 0 {
        XCTAssert(peopleViewModel.displayedUserSections[0].users[0].name == "Amir Tiwari", "Result is not specific user")
        }
        else {
            XCTFail("no results for 'amir tiwari' search")
        }
    }
}