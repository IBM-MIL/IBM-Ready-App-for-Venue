/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import XCTest
@testable import Venue

class ChallengesTests : XCTestCase {
        
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        MockTest.initializeData()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
    Verifies we get data from Core Data
    */
    func testBadgeCollectionViewModel() {
        let viewModel = BadgeCollectionViewModel()
        XCTAssertGreaterThanOrEqual(viewModel.challenges.count, 0)
    }
    
    /**
    Verifies we get leaders and that points were calculated correctly
    */
    func testLeaderboardViewModel() {
        
        let viewModel = LeaderboardViewModel()
        XCTAssertGreaterThanOrEqual(viewModel.leaders.count, 0)
        
        XCTAssertNotNil(viewModel.currentUser, "Current user was not located correctly")
        
        XCTAssertEqual(viewModel.leaders.count, viewModel.userPoints.count, "Points were not calculated for the correct amount of users: \(viewModel.leaders.count)")
        
        /* Test individual methods */
        
        viewModel.calculateLeaderPoints(viewModel.leaders)
        for user in viewModel.leaders {
            let sum = user.challengesCompleted.reduce(0) { $0 + $1.pointValue }
            let previousTotal = viewModel.userPoints[user.id]
            XCTAssertEqual(sum, previousTotal, "Totals are not consistent with each other")
        }
        
        for _ in 0...5 {
            // Mix up array
            var mixedUsers = viewModel.leaders
            mixedUsers.shuffle()
            let sortedUsers = viewModel.sortUsersByChallenges(mixedUsers, userPoints: viewModel.userPoints)
            
            // Confirm array was sorted correctly every time
            var previousTotal: Int = -1
            for user in sortedUsers {
                
                let currentPoints = viewModel.userPoints[user.id]!
                if previousTotal >= 0 {
                    XCTAssertLessThanOrEqual(currentPoints, previousTotal)
                    previousTotal = currentPoints
                } else {
                    previousTotal = currentPoints
                }
                
            }
        }
        
    }
    
    /**
    Confirms we get user data and points are being displayed correctly
    */
    func testLeaderboardDetailViewModel() {
        
        // Prep: grab user from other viewModel
        let leaderboardViewModel = LeaderboardViewModel()
        let currentUser = leaderboardViewModel.currentUser
        
        let viewModel = LeaderboardDetailViewModel()
        viewModel.user = currentUser
        
        XCTAssertNotEqual(viewModel.user.challengesCompleted.count, 0, "There are no challenges completed")
        
        let userPointTotal = viewModel.challengePoints()
        var total = 0
        for challenges in viewModel.user.challengesCompleted {
            total += challenges.pointValue
        }
        XCTAssertEqual(userPointTotal, total, "Point values don't match up: \(userPointTotal) != \(total)")
        
    }
}
