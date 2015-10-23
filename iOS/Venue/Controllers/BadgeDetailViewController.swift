/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  UIViewController used to view the details of a badge
*/
class BadgeDetailViewController: VenueUIViewController {
    
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Info about the challenge everyone knows
    var challenge: Challenge?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateUI()
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
        if let challenge = challenge {
            self.title = challenge.name
        }
        
        // Remove 1px shadow under nav bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func populateUI() {
        
        // Not using a view model because data is very minimal for this screen
        if let challenge = challenge {
            let boldAttr = [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)]
            let attributedString =  NSMutableAttributedString(string: challenge.details + NSLocalizedString(" Worth ", comment: ""))
            attributedString.appendAttributedString(NSMutableAttributedString(string: String(challenge.pointValue), attributes: boldAttr))
            attributedString.appendAttributedString(NSAttributedString(string: NSLocalizedString(" points.", comment: "")))
            titleLabel.attributedText = attributedString
            badgeImageView.image = UIImage(named: challenge.imageUrl)
        }
        
    }
    
    func popVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

// MARK: - UITableView Methods

extension BadgeDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let challenge = challenge {
            return challenge.tasksNeeded.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("badgeDetailCell") as? BadgeDetailViewCell, let challenge = challenge else {
            return UITableViewCell()
        }
        let challengeTask = challenge.tasksNeeded[indexPath.row]
        cell.nameLabel.text = challengeTask.name
        if user?.tasksCompleted.filter({$0.id == challengeTask.id}).count > 0 {
            cell.completeImageView.hidden = false
        }
        else {
            cell.completeImageView.hidden = true
        }
        return cell
    }
}
