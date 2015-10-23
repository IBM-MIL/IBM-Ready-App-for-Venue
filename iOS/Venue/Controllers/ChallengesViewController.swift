/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// ViewController to handle leaderboard and badges views
class ChallengesViewController: VenueUIViewController {
    
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var badgesButton: UIButton!
    
    /// UIView beneath the top buttons indicating which is selected
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var badgeContainerView: UIView!
    @IBOutlet weak var leaderboardContainerView: UIView!
    
    /// Constant used to animate the movement of the indicator view
    @IBOutlet weak var indicatorViewLeadingContraint: NSLayoutConstraint!
    
    var showingBadges = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /**
    Setup ReactiveCocoa bindings to UI and data
    */
    func setupBindings() {
        
        leaderboardButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [unowned self] _ in
            self.showingBadges = false
            self.reloadView()
        }
        
        badgesButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [unowned self] _ in
            self.showingBadges = true
            self.reloadView()
        }
    }
    
    /**
    Reloads the collection view based on the state of the showingNearest bool
    */
    func reloadView() {
        leaderboardButton.titleLabel?.font = !showingBadges ? UIFont.latoBlack(14.0) : UIFont.latoRegular(14.0)
        badgesButton.titleLabel?.font = showingBadges ? UIFont.latoBlack(14.0) : UIFont.latoRegular(14.0)
        badgeContainerView.hidden = !showingBadges
        leaderboardContainerView.hidden = showingBadges
        indicatorViewLeadingContraint.constant = showingBadges ? 0 : view.frame.size.width/2
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "badgeSegue" {
            let vc = segue.destinationViewController as? BadgeViewController
            if vc!.viewModel == nil {
                vc!.viewModel = BadgeCollectionViewModel()
            }
        } else if segue.identifier == "leaderboardSegue" {
            let vc = segue.destinationViewController as? LeaderboardViewController
            if vc!.viewModel == nil {
                vc!.viewModel = LeaderboardViewModel()
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

