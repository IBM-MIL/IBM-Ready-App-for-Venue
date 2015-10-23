/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import Foundation

/// Controller to handle all alerts/notifications a user receives
class NotificationsViewController: VenueUIViewController {
  
    var viewModel = NotificationsViewModel()
    let filterTableViewHeight: CGFloat = 120
    
    @IBOutlet weak var filterTableView: UITableView!
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var filterTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var dropdownArrowImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure tableView rows resize based on content
        notificationsTableView.rowHeight = UITableViewAutomaticDimension
        notificationsTableView.estimatedRowHeight = 120.0

        setupBindings()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        countUnread()
    }
    
    /**
    Setup ReactiveCocoa bindings to UI and data
    */
    func setupBindings() {
        
        filterButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).deliverOnMainThread().subscribeNext{ [unowned self] _ in
            self.animateFilterMenu()
        }
        
        RACObserve(viewModel, keyPath: "alertList").deliverOnMainThread().subscribeNext{ [unowned self] _ in
            
            self.countUnread()
            self.notificationsTableView.reloadData()
        }
        
        // Reloads filter tableView when filter menu goes up and down
        RACObserve(viewModel, keyPath: "isMenuVisible").deliverOnMainThread().subscribeNext{ [unowned self] _ in
            self.filterTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Sometimes 2 line titles are set before table reloads somehowa
        notificationsTableView.reloadData()
    }
    
    func countUnread() {
        var badgeCount = 0
        
        for alert in self.viewModel.alertList {
            if alert.unread {
                badgeCount++
            }
        }
        
        if badgeCount > 0 {
            self.navigationController?.tabBarItem.badgeValue = "\(badgeCount)"
        } else {
            self.navigationController?.tabBarItem.badgeValue = nil
        }
    }
    
    /**
    Method to handle filter menu presentation and state
    */
    func animateFilterMenu() {
        
        // Animate notificationTableView as needed, up or down
        if self.viewModel.isMenuVisible {
            
            // Hide filter menu
            self.filterTableViewTopConstraint.constant = -120
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.45, initialSpringVelocity: 10, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.notificationsTableView.frame = CGRectOffset(self.notificationsTableView.frame, 0, -self.filterTableViewHeight)
                self.notificationsTableView.frame.size.height += self.filterTableViewHeight
                
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            self.dropdownArrowImageView.image = UIImage(named: "alerts_inbox_down_arrow")
            self.filterButton.setTitle(viewModel.selectedMenuItem, forState: UIControlState.Normal)
            self.viewModel.isMenuVisible = false
        }
        else {
            
            // Show filter menu
            self.filterTableViewTopConstraint.constant = 0
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.45, initialSpringVelocity: 10, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.notificationsTableView.frame = CGRectOffset(self.notificationsTableView.frame, 0, self.filterTableViewHeight)
                self.notificationsTableView.frame.size.height -= self.filterTableViewHeight
                
                self.view.layoutIfNeeded()
            }, completion: nil)

            self.dropdownArrowImageView.image = UIImage(named: "alerts_inbox_up_arrow")
            self.filterButton.setTitle(NSLocalizedString("Filter Inbox", comment: "n/a"), forState: UIControlState.Normal)
            self.viewModel.isMenuVisible = true
        }
        
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // Delegate method handles both tableViews
        if tableView == filterTableView {
            return 3
        } else {
            return viewModel.alertList.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == filterTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! NotificationMenuTableViewCell
            return viewModel.setupMenuCellAtIndex(indexPath.row, cell: cell)
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("NotificationItem", forIndexPath: indexPath) as! NotificationTableViewCell
            return viewModel.setupNotificationCellAtIndex(indexPath.row, cell: cell)
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView == filterTableView {
            
            // Notify viewModel, this cell was selected
            viewModel.didSelectMenuItem(indexPath.row, isMenuVisible: viewModel.isMenuVisible)
            animateFilterMenu()
            
        } else {
            // If notificationCell selected, mark as read and reload that cell
            viewModel.alertList[indexPath.row].unread = false
            notificationsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            let alertDetailVC = Utils.vcWithNameFromStoryboardWithName("NotificationDetailViewController", storyboardName: "Alerts") as! NotificationDetailViewController
            alertDetailVC.alertData = viewModel.alertList[indexPath.row]
            self.navigationController?.pushViewController(alertDetailVC, animated: true)
            
        }
    }
}
