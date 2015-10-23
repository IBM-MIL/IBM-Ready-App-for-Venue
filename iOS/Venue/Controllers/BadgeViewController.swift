/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Displays a user's badges they have earned
*/
class BadgeViewController: VenueUIViewController {
    
    @IBOutlet weak var badgeCollectionView: UICollectionView!
    
    var viewModel: BadgeCollectionViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionCellSize()
        setupBindings()
        
    }
    
    /**
    Setup ReactiveCocoa bindings to UI and data
    */
    func setupBindings() {
        
        RACObserve(viewModel!, keyPath: "challenges").deliverOnMainThread().subscribeNext{ [unowned self] _ in
            self.badgeCollectionView.reloadData()
        }
        
        RACObserve(UserDataManager.sharedInstance.currentUser, keyPath: "tasksCompleted").subscribeNext({ [unowned self] _ in
            self.badgeCollectionView.reloadData()
        })
        
    }
    
    func setCollectionCellSize() {
        let cellWidth = (self.view.frame.width - 40)/2
        let newLayout = UICollectionViewFlowLayout()
        
        newLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        newLayout.minimumInteritemSpacing = 10
        newLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        badgeCollectionView.collectionViewLayout = newLayout
        
        badgeCollectionView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - UICollectionView Methods

extension BadgeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
        
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! BadgeCollectionViewCell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? BadgeCollectionViewCell {
            viewModel!.setupBadgeCell(cell, row: indexPath.row)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.challenges.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! BadgeCollectionHeaderView
            headerView.headerLabel.text = NSLocalizedString("Compete against your friends and others to earn badges and exclusive offers.", comment: "n/a")
            
            return headerView
        } else {
            // Should only happen if storyboard not configured right
            MQALogger.log("Unexpected element kind", withLevel: MQALogLevelError)
            return UICollectionReusableView()
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let badgeDetailViewController = Utils.vcWithNameFromStoryboardWithName("BadgeDetailViewController", storyboardName: "Challenges") as? BadgeDetailViewController {
            badgeDetailViewController.challenge = viewModel!.challenges[indexPath.row]
            badgeDetailViewController.user = viewModel?.currentUser
            navigationController?.pushViewController(badgeDetailViewController, animated: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return Utils.sizeOfCellForCollectionView(collectionView, horizontalPadding: 40.0, cellRatio: 8.5/9.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.size.width, height: 75)
    }
}