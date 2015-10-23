/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

/// This class handles the view for the POI detail screen
class PlaceDetailViewController: VenueUIViewController {

    // Views
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerImageOverlay: UIView!
    @IBOutlet weak var waitTimeView: UIView!
    @IBOutlet weak var waitMinuteLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailsTitleLabel: UILabel!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var mapImageView: UIImageView!
    
    // Constraints
    @IBOutlet weak var headerImageAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var croppedMapBottomConstraint: NSLayoutConstraint!
    
    let padding: CGFloat = 15.0
    var navBarTranslucent = true
    var headerHeight: CGFloat!
    var viewModel: PlacesDetailViewModel?
    var inviteSent = false
    var inviteString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "mapSelected")
        self.mapImageView.addGestureRecognizer(tapGestureRecognizer)
        self.mapImageView.userInteractionEnabled = true
        
        detailsTableView.scrollEnabled = false
        inviteButton.layer.cornerRadius = (inviteButton.frame.size.height / 2)
        inviteButton.clipsToBounds = true
        
        setupNavigationBar()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup UI
        headerImageView.image = UIImage(named: viewModel!.poi.pictureUrl)
        titleLabel.text = viewModel!.poi.name
        descriptionLabel.text = viewModel!.poi.descriptionDetail// NSAttributedString(string: viewModel!.poi.descriptionDetail)
        detailsTitleLabel.text = viewModel!.poi.getFirstTypeString() + " Details"
        setupWaitTimeLabel()
        setupBindings()
        
        // Checks to see if we need to display the invite confirmation banner
        if inviteSent {
            if let inviteString = inviteString {
                DemoManager.displayBanner(inviteString)
            }
            inviteSent = false
        }
        
        // Make sure navigation bar is translucent
        if !navBarTranslucent {
            showNavigationBar()
        }
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Tell table view to reload so we can determine how big to make the table view
        detailsTableView.reloadData()
        tableViewHeightConstraint.constant = detailsTableView.contentSize.height
        if let viewModel = viewModel {
            if viewModel.poi.details.count == 0 {
                tableViewHeightConstraint.constant = 0
            }
        }
        self.view.updateConstraints()
        

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Make sure header image is 16:9 and then remove aspect ratio constraint so we can change height later
        if let headerImageAspectRatioConstraint = headerImageAspectRatioConstraint {
            headerHeight = headerImageView.frame.size.height
            headerImageHeightConstraint.constant = headerHeight
            headerImageView.removeConstraint(headerImageAspectRatioConstraint)
            
            // Add a little buffer at the bottom of the scroll view so that the header image can be completely scrolled behind the nav bar.
            if let navigationController = navigationController {
                let navBarTotalHeight = navigationController.navigationBar.frame.origin.y + navigationController.navigationBar.frame.size.height
                let range = headerHeight - navBarTotalHeight
                let scrollableHeight = contentView.height - scrollView.height
                if scrollableHeight > 0 {
                    croppedMapBottomConstraint.constant = range - scrollableHeight
                }
            }
            
            self.view.updateConstraints()
        }
        
        // Get cropped map image and add pin
        if mapImageView.image == nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let croppedImage = self.viewModel!.croppedMapImage(self.mapImageView.width, height: self.mapImageView.height)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapImageView.image = croppedImage
                    
                    // Get the pin to add to the correct point
                    let firstType = self.viewModel!.poi.types.first!
                    let pinImage = UIImage(named: firstType.pin_image_name)!
                    let pinX = (self.mapImageView.frame.size.width / 2) - (pinImage.size.width / 2)
                    let pinY = (self.mapImageView.frame.size.height / 2) - (pinImage.size.height)
                    let pinImageView = UIImageView(image: pinImage)
                    var pinOffset = CGPoint(x: pinX, y: pinY)
                    pinOffset = self.viewModel!.applyPinOffset(pinOffset)
                    pinImageView.setOrigin(pinOffset)
                    self.mapImageView.addSubview(pinImageView)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toInvite" {
            if let viewModel = viewModel {
                let placeInvite = segue.destinationViewController as! PlaceInviteViewController
                placeInvite.viewModel = PlaceInviteViewModel(location: viewModel.poi)
            }
        }
    }
    
    /**
    Set up the wait time label text and background color. If there isn't a valid wait time, the 
    view will be hidden.
    */
    func setupWaitTimeLabel() {
        
        guard let viewModel = viewModel else {
            waitTimeView.hidden = true
            return
        }
        
        // Setup wait time label text
        waitMinuteLabel.text = viewModel.getWaitTimeText()
        if waitMinuteLabel.text == "" {
            waitTimeView.hidden = true
            return
        }
        
        // Setup wait circle view color
        waitTimeView.backgroundColor = viewModel.getWaitTimeColor()
    }
    
    /**
    Sets up a Reactive Binding to change the image of the favorite button
    */
    func setupBindings() {
        RACObserve(self.viewModel!, keyPath: "favoriteImageName").subscribeNextAs({ [weak self] (favoriteImageName: String) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navItem.rightBarButtonItem?.image = UIImage(named: favoriteImageName)
        })
    }
    
    /**
    Sets up the custom nav bar to be completely translucent with a back button and a favorite button
    */
    func setupNavigationBar() {

        self.navBar.shadowImage = UIImage()
        
        // Set backbutton here to avoid text from previous screen animating over
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("backButtonPressed"))
        self.navItem.leftBarButtonItem = nil
        self.navItem.leftBarButtonItem = backButton
        
        // Setup favorited button
        let favoriteButton = UIBarButtonItem(image: UIImage(named: viewModel!.favoriteImageName), style: UIBarButtonItemStyle.Done, target: self, action: Selector("favoritedButtonPressed"))
        self.navItem.rightBarButtonItem = favoriteButton
        
        // set navigation bar to transparent
        self.navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navBar.translucent = true
    }
    
    /**
    Shows the navigation bar as opaque blue.
    */
    func showNavigationBar() {
        navBarTranslucent = false
        navBar.setBackgroundImage(nil,forBarMetrics: UIBarMetrics.Default)
        navBar.barTintColor = UIColor.venueLightBlue()
        navBar.translucent = false
    }
    
    /**
    Makes the nav bar completely translucent
    */
    func hideNavigationBar() {
        navBarTranslucent = true
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.barTintColor = UIColor.clearColor()
        navBar.translucent = true
    }
    
    func backButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func favoritedButtonPressed() {
        self.viewModel?.favoritedIconSelected()
        DemoManager.displayBanner(viewModel!.bannerString())
    }
    
    /**
    When the map is selected, tell the tab bar!
    */
    func mapSelected(){
        guard let tabBarController = self.tabBarController as? TabBarViewController else {
            return
        }
        
        tabBarController.selectMapTab(poi: self.viewModel!.poi, user: nil)
    }
}

// MARK: UIBarPositioningDelegate

/// Tells the custom nar bar to draw behind the status bar at the top of the screen
extension PlaceDetailViewController: UIBarPositioningDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}

// MARK: UIScrollViewDelegate

extension PlaceDetailViewController: UIScrollViewDelegate {
    
    /**
    Handles what happens when you scroll. This might stretch the header image if you pull down, or fade
    in the blue nav bar at the top when you scroll up.
    */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // If pulling down, stretch the header image at the top
        if scrollView.contentOffset.y < 0 {
            headerImageTopConstraint.constant = scrollView.contentOffset.y
            
            // Fix for 8.4 nil header.
            guard headerHeight != nil else {
                return
            }
            headerImageHeightConstraint.constant = headerHeight - (scrollView.contentOffset.y)
            self.view.updateConstraints()
        }
        // Update opacity over header image
        let navBarTotalHeight = self.navBar.frame.origin.y + self.navBar.frame.size.height
        let range = headerHeight - navBarTotalHeight
        let percentage = scrollView.contentOffset.y / range
        headerImageOverlay.alpha = percentage
    
        // Determine if we want to show the blue nav bar or see through nav bar
        if (headerHeight - scrollView.contentOffset.y) <= navBarTotalHeight {
            if navBarTranslucent {
                showNavigationBar()
            }
        } else {
            if !navBarTranslucent {
                hideNavigationBar()
            }
        }
    }
}

// MARK: UITableView Delegate and Data Source

extension PlaceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            return 0
        }
        
        return viewModel.poi.details.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TypeDetailsCell") as! POIDetailsTableViewCell
        viewModel?.setupDetailCell(cell, indexPath: indexPath)
        return cell
    }
}