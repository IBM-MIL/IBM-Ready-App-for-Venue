/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// UIViewController used to view the details of a leaderboard user
class LeaderboardDetailViewController: VenueUIViewController {
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var avatarPlaceholderLabel: UILabel!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    var viewModel: LeaderboardDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()

        nameLabel.text = viewModel!.user.name
        pointsLabel.text = String(viewModel!.challengePoints()) + " PTS"
        profileImageView.image = UIImage(named: viewModel!.user.pictureUrl)
        avatarPlaceholderLabel.text = viewModel!.user.initials
        avatarPlaceholderLabel.layer.cornerRadius = avatarPlaceholderLabel.frame.size.height / 2
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    /**
    Style native navigationBar to avoid any UI issues
    */
    func setupNavigationBar() {
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Setup back button as just an arrow
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("popVC"))
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = backButton
        if let viewModel = viewModel {
            self.title = viewModel.user.name
        }
        
        // Remove 1px shadow under nav bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()

        navigationItem.title = viewModel!.user.id == UserDataManager.sharedInstance.currentUser.id ?  NSLocalizedString("Your Score", comment: "") :  NSLocalizedString("Player's Score", comment: "")
    }
    
    /**
    Setup ReactiveCocoa bindings to UI and data
    */
    func setupBindings() {
        
        RACObserve(viewModel!.user, keyPath: "challengesCompleted").deliverOnMainThread().subscribeNext{ [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.detailCollectionView.reloadData()
            strongSelf.pointsLabel.text = String(self!.viewModel!.challengePoints()) + " PTS"
        }
        
        RACObserve(UserDataManager.sharedInstance.currentUser, keyPath: "challengesCompleted").subscribeNextAs({ [weak self] (challenges: [Challenge]) in
            guard let strongSelf = self else {
                return
            }
            
            guard strongSelf.viewModel!.user.id == UserDataManager.sharedInstance.currentUser.id else {
                return
            }
            strongSelf.viewModel!.user.challengesCompleted = challenges
        })
        
    }
    
    func popVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

extension LeaderboardDetailViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! BadgeCollectionViewCell
        
        return viewModel!.setupBadgeCell(cell, row: indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.user.challengesCompleted.count
    }
    
}

extension LeaderboardDetailViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let badgeDetailViewController = Utils.vcWithNameFromStoryboardWithName("BadgeDetailViewController", storyboardName: "Challenges") as? BadgeDetailViewController {
            badgeDetailViewController.user = viewModel!.user
            badgeDetailViewController.challenge = viewModel!.user.challengesCompleted[indexPath.row]
            navigationController?.pushViewController(badgeDetailViewController, animated: true)

        }
    }
    
}

extension LeaderboardDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Utils.sizeOfCellForCollectionView(collectionView, horizontalPadding: 40.0, cellRatio: 8.0/9.0)
    }
}

