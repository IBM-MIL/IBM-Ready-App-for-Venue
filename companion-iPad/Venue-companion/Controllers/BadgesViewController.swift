/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class BadgesViewController: UIViewController {
    
    
    var challenges: [Challenge] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = ApplicationDataManager.sharedInstance.currentUser else {
            return
        }

        // Do any additional setup after loading the view.
        challenges = currentUser.challengesCompleted
        if challenges.count < 4 {
            
            // TODO: Think of better way to do this. This is not well optimized.
            
            var challengeProgress: [Challenge: Double] = [:]
            for challenge in ApplicationDataManager.sharedInstance.challenges {
                
                var progress = 0
                for neededTask in challenge.tasksNeeded {
                    for completedTask in currentUser.tasksCompleted {
                        if completedTask.id == neededTask {
                            progress++
                        }
                    }
                }
                challengeProgress[challenge] = Double(progress)/Double(challenge.tasksNeeded.count)
            }
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension BadgesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challenges.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("badgeCell", forIndexPath: indexPath) as? BadgeCollectionViewCell {
            if let image = UIImage(named: challenges[indexPath.row].imageUrl) {
                cell.imageView.image = image
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}

extension BadgesViewController: UICollectionViewDelegate {
    
}
