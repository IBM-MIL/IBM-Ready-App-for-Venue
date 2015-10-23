/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// View model to display details of particular badge and a user's progress
class LeaderboardDetailViewModel: NSObject {
    
    var user: User!
    
    override init() {
        super.init()
    }
    
    /**
    Calculates points from challengesCompleted
    
    - returns: sum of challenge points
    */
    func challengePoints() -> Int {
        
        return user.challengesCompleted.reduce(0) { $0 + $1.pointValue }
    }
    
    /**
    Configures collectionView cell with userChallenge data
    
    - parameter cell: a BadgeCollectionViewCell
    - parameter row:  index in collectionView
    
    - returns: modified collectionView cell
    */
    func setupBadgeCell(cell: BadgeCollectionViewCell, row: Int) -> BadgeCollectionViewCell {
        let challenge = user.challengesCompleted[row]
        
        cell.badgeImageView.image = UIImage(named: challenge.thumbnailUrl)
        
        cell.badgeTitle.text = challenge.name
        
        return cell
        
    }
}
