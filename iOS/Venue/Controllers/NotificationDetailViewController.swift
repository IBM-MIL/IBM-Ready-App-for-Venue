/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// Controller handling notification details whether it is just info or an invitation
class NotificationDetailViewController: VenueUIViewController{

    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var forwardArrowImageView: UIImageView!
    
    @IBOutlet weak var primaryDetailView: UIView!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailSubtitleLabel: UILabel!
    @IBOutlet weak var topBodyLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBodyLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptInviteButton: UIButton!
    @IBOutlet var detailTapGesture: UITapGestureRecognizer!
    
    /// Notificatin passed in from NotificationsViewController
    var alertData: Notification?
    let primaryDetailViewHeight: CGFloat = 67
    let acceptButtonHeight: CGFloat = 57
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        navigationController?.navigationBar.barTintColor = UIColor.venueLightBlue()
        navigationController?.navigationBar.translucent = false
        
        // Setup back button as just an arrow
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("popVC"))
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = backButton
        self.title = NSLocalizedString("Notification Details", comment: "")
        
        // Remove 1px shadow under nav bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    /**
    Method handling display of appropriate UI based on data present
    */
    func populateUI() {
        if let alertData = alertData {
            
            // If invite present, show that UI
            if let invite = alertData.invitation {
                detailImageView.image = UIImage(named: invite.location.thumbnailUrl)
                detailLabel.text = invite.location.name
                detailSubtitleLabel.text = invite.timestampToMeet.localizedStringTime()
                primaryDetailView.hidden = false
                
                // If invitation accepted, style invite button to show that
                if UserDataManager.sharedInstance.currentUser.invitationsAccepted.contains(invite) {
                    setInviteButtonAccepted()
                }
                setupBindings()
            } else {
                // Hide invite UI elmeents
                acceptInviteButton.hidden = true
                topBodyLabelConstraint.constant -= primaryDetailViewHeight
                bottomBodyLabelConstraint.constant -= acceptButtonHeight
            }
            
            timestampLabel.text = alertData.timestamp.localizedStringTime()
            titleLabel.text = alertData.title
            bodyLabel.text = alertData.message
        } else {
            MQALogger.log("No Notification data to display")
        }
        forwardArrowImageView.image = forwardArrowImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    }
    
    /**
    Setup ReactiveCocoa bindings to UI and data
    */
    func setupBindings() {
        
        acceptInviteButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [unowned self] _ in
            if let invite = self.alertData?.invitation {
                // Add invite to accepted list
                let user = UserDataManager.sharedInstance.currentUser
                user.invitationsAccepted.append(invite)
                
                // Alter UI to show invite was accepted
                DemoManager.displayBanner(NSLocalizedString("Invitation has been accepted!", comment: ""))
                self.setInviteButtonAccepted()
            }
        }
        
        detailTapGesture.rac_gestureSignal().subscribeNext { [unowned self] _ in
            if let invite = self.alertData?.invitation {
                let poiDetailVC = Utils.vcWithNameFromStoryboardWithName("placeDetail", storyboardName: "Places") as! PlaceDetailViewController
                poiDetailVC.viewModel = PlacesDetailViewModel(poi: invite.location)
                self.navigationController?.pushViewController(poiDetailVC, animated: true)
            }
        }
    }
    
    /**
    Performs state change of invite accept button
    */
    func setInviteButtonAccepted() {
        self.acceptInviteButton.setTitle(NSLocalizedString("Accepted", comment: ""), forState: UIControlState.Normal)
        self.acceptInviteButton.backgroundColor = UIColor.venueLightGreen()
        self.acceptInviteButton.enabled = false
    }

    func popVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
