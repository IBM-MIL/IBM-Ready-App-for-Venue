/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import XCTest
@testable import Venue

class NotificationTests : XCTestCase {
    
    var viewModel: NotificationsViewModel!

    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        MockTest.initializeData()
        viewModel = NotificationsViewModel()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Main Tests
    
    /**
    Verifies notifications view data and filters were configured correctly
    */
    func testInitialSetup() {
        
        XCTAssertGreaterThan(viewModel.originalAlertList.count, 0)
        XCTAssertGreaterThan(viewModel.alertList.count, 0)
        XCTAssertFalse(viewModel.isMenuVisible)
        XCTAssertEqual(viewModel.menuItems.count, 3)
        
        XCTAssertEqual(viewModel.menuItems[0], FilterType.All)
        XCTAssertEqual(viewModel.menuItems[1], FilterType.Invites)
        XCTAssertEqual(viewModel.menuItems[2], FilterType.Notification)
        
        var inviteFound = false
        for notification in viewModel.originalAlertList {
            if let _ = notification.invitation {
                inviteFound = true
                break
            }
        }
        XCTAssertTrue(inviteFound, "No invites were found in list of notifications")
    }
    
    /**
    Tests that we can filter notifications accurately
    */
    func testFiltering() {
        
        let firstItem = viewModel.menuItems.first
        XCTAssertEqual(firstItem, viewModel.selectedMenuItem, "First items are not equal when they should be")
        
        viewModel.didSelectMenuItem(1, isMenuVisible: true)
        XCTAssertNotEqual(firstItem, viewModel.selectedMenuItem, "selectedMenuItem did not change from previous value")
        XCTAssertEqual(viewModel.menuItems[viewModel.selectedIndex], viewModel.selectedMenuItem, "selectedMenuItem was not computed properly")
        
        viewModel.didSelectMenuItem(2, isMenuVisible: true)
        XCTAssertNotEqual(firstItem, viewModel.selectedMenuItem, "selectedMenuItem did not change from previous value")
        XCTAssertEqual(viewModel.menuItems[viewModel.selectedIndex], viewModel.selectedMenuItem, "selectedMenuItem was not computed properly")
        
        /* Test filtering method */
        
        let originalList = viewModel.originalAlertList
        var filtered = viewModel.filterAlertsBy(FilterType.Invites)
        XCTAssertNotEqual(originalList.count, filtered.count, "View model list was not filtered correctly for invites")
        
        for item in filtered {
            XCTAssertEqual(item.type, "invitation", "Filtering incorrect, item was not an invitation")
        }
        
        filtered = viewModel.filterAlertsBy(FilterType.Notification)
        XCTAssertNotEqual(originalList.count, filtered.count, "View model list was not filtered correctly for notifications")
        
        for item in filtered {
            XCTAssertEqual(item.type, "alert", "Filtering incorrect, item was not an alert")
        }
        
        filtered = viewModel.filterAlertsBy(FilterType.All)
        XCTAssertEqual(originalList.count, filtered.count, "Original lists should be equal, but are different")
        XCTAssertEqual(originalList, filtered, "Arrays are different when they have same source")
    }
    
    /**
    Tests that notifications were sorted by timestamp correctly
    */
    func testUtilities() {
                
        // Verify timestamp sorting
        var previousNotification: Notification?
        for notification in viewModel.originalAlertList {

            if let previousNotification = previousNotification {
                XCTAssertGreaterThanOrEqual(previousNotification.timestamp.timeIntervalSinceReferenceDate, notification.timestamp.timeIntervalSinceReferenceDate, "The previous notification is later than the current one")
            } else {
                previousNotification = notification
            }
            
        }
        
    }
}
