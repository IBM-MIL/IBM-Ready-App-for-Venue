/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// Handles badge data and UI calculations
class BadgeCollectionViewModel: NSObject {
    
    dynamic var challenges = [Challenge]()
    var currentUser: User
    
    override init() {
        currentUser = UserDataManager.sharedInstance.currentUser
        super.init()
        
        ChallengeDataManager.sharedInstance.getChallenges { [weak self] (challenges: [Challenge]) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.challenges = challenges
        }
    }
    
    /**
    Configures collectionView cell with challenge data and progress view overlay
    
    :param: cell a BadgeCollectionViewCell
    :param: row  index in collectionView
    
    :returns: modified collectionView cell
    */
    func setupBadgeCell(cell: BadgeCollectionViewCell, row: Int) -> BadgeCollectionViewCell {
        
        let currentChallenge = challenges[row]
        
        cell.badgeImageView.image = UIImage(named: challenges[row].thumbnailUrl)
        
        let progressView = CERoundProgressView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: cell.badgeImageView.width, height: cell.badgeImageView.height) ))
        
        var tasksNeededComplete = 0
        for task in currentChallenge.tasksNeeded {
            if currentUser.tasksCompleted.filter({$0.id == task.id}).count > 0 {
                tasksNeededComplete++
            }
        }
        
        let percentCompleted = Double(tasksNeededComplete) / Double(currentChallenge.tasksNeeded.count)
        
        progressView.startAngle = Float(M_PI * 1.5 + 2 * M_PI * percentCompleted)
        progressView.tintColor = UIColor.darkGrayColor()
        progressView.trackColor = UIColor.clearColor()
        progressView.setProgress(1 - Float(percentCompleted), animated: false)
        progressView.alpha = 0.7
        
        cell.badgeImageView.addSubview(progressView)
        
        cell.badgeTitle.text = currentChallenge.name
        
        return cell
    }
}
