/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// Handles all users on the leaderboard, there order, and points total
class LeaderboardViewModel: NSObject {
    
    dynamic var leaders = [User]()
    var userPoints = [Int : Int]()
    var currentUser: User!
    
    override init() {
        
        super.init()
        
        UserDataManager.sharedInstance.getUsers(UserDataManager.sharedInstance.currentUser.group.id) { [weak self] (users: [User]) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.leaders = users
            
            strongSelf.currentUser = UserDataManager.sharedInstance.currentUser
            
            strongSelf.calculateLeaderPoints(strongSelf.leaders)
            strongSelf.leaders = strongSelf.sortUsersByChallenges(strongSelf.leaders, userPoints: strongSelf.userPoints)
        }
    }
    
    /**
    Updates current user's score
    */
    func updateLeaderScore() {
        for leader in leaders {
            if leader.id == UserDataManager.sharedInstance.currentUser.id {
                leader.challengesCompleted = UserDataManager.sharedInstance.currentUser.challengesCompleted
                self.calculateLeaderPoints(self.leaders)
                self.leaders = self.sortUsersByChallenges(self.leaders, userPoints: self.userPoints)

            }
        }
    }
    
    /**
    Configures tableview cell with user data
    
    :param: cell a LeaderboardTableViewCell
    :param: row  index in tableview
    
    :returns: modified tableview cell
    */
    func setupLeaderboardCell(cell: LeaderboardTableViewCell, row: Int) -> LeaderboardTableViewCell {

        let leader = leaders[row]
        if currentUser.id == leader.id {
            cell.contentView.backgroundColor = UIColor(red: 227.0/255.0, green: 239.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        } else {
            cell.contentView.backgroundColor = UIColor(red: 252/255.0, green: 252/255.0, blue: 252/255.0, alpha: 1.0)
        }
        
        cell.usernameLabel.text = leader.name
        cell.rankLabel.text = "\(row + 1)"
        
        if let points = userPoints[leader.id] {
            cell.pointsLabel.text = "\(points)"
        }
        
        cell.avatarPlaceholderLabel.text = leader.initials
        
        if leader.pictureUrl != "" {
            cell.profileImageView.image = UIImage(named: leader.pictureUrl)
        }
        
        return cell
    }
    
    /**
    Method to calculate the sum of points a user has based on their challenges
    
    :param: leaders users to calculate points for
    
    :returns: dictionary mapping userID to points earned
    */
    func calculateLeaderPoints(leaders: [User]) {
        
        for leader in leaders {
            let sum = leader.challengesCompleted.reduce(0) { $0 + $1.pointValue }
            userPoints[leader.id] = sum
        }
    }
    
    /**
    Sorting method of leaderboard tableview data
    
    :param: users      users to be sorted
    :param: userPoints point dictionary for every user in leaderboard
    
    :returns: array of sorted users by points
    */
    func sortUsersByChallenges(users: [User], userPoints: [Int:Int]) -> [User] {
        var sortedUsers = [User]()
        
        // sort dictionary by value and iterate through
        for (k,_) in (Array(userPoints).sort {$0.1 > $1.1}) {
            for user in users {
                // append to sorted array with updated order
                if user.id == k {
                    sortedUsers.append(user)
                }
            }
        }
        
        return sortedUsers
    }
}
