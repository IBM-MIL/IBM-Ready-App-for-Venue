/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import AVFoundation

/// Controller to serve as a starting point, showing the user's list of POIs and all POIs near them
class HomeViewController: VenueUIViewController {

    @IBOutlet weak var fillerTableViewHeader: UIView!
    @IBOutlet weak var myListButton: UIButton!
    @IBOutlet weak var nearMeButton: UIButton!
    @IBOutlet weak var leadingIndicatorViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var shadowImageView: UIImageView!
    @IBOutlet weak var emptyButtonTableViewHeader: UIView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var avPlayerView: UIView!
    @IBOutlet var completedSectionHeader: UIView!
    @IBOutlet var invitationSectionHeader: UIView!
    @IBOutlet var favoritesSectionHeader: UIView!
    @IBOutlet weak var favoritesHeaderLabel: UILabel!
    
    /// Helper setter to be used when we want to keep overlayView and buttonView colors in sync
    var overlayColor: UIColor {
        get {
            return overlayView.backgroundColor!
        }
        set(color) {
            overlayView.backgroundColor = color
            buttonView.backgroundColor = color
        }
    }
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!

    var viewModel = HomeViewModel()
    
    // Local constants
    
    let headerVideoHeight: CGFloat = 234.0
    let customNavBarHeight: CGFloat = 66.0
    let yOffset: CGFloat = -20.0

    override func viewDidLoad() {
        super.viewDidLoad()
        overlayColor = UIColor.venueLightBlue().colorWithAlphaComponent(0.0)
        setupBindings()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /**
    Setup ReactiveCocoa bindings to UI and data
    */
    func setupBindings() {
        
        // Listener to ensure video playback loops to the beginning every time it ends
        NSNotificationCenter.defaultCenter().rac_addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil)
            .deliverOnMainThread()
            .subscribeNextAs { [unowned self] (notification: NSNotification) in
                if let player = notification.object as? AVPlayerItem {
                    self.restartVideo(player)
                    self.avPlayer.play()
                }
        }

        // Listener to restart player when coming from an inactive state
        NSNotificationCenter.defaultCenter().rac_addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil)
            .deliverOnMainThread()
            .subscribeNextAs { [weak self] (notification: NSNotification) in
                MQALogger.log("App and Home screen have entered foreground", withLevel: MQALogLevelInfo)
                
                guard let strongSelf = self else {
                    return
                }
                strongSelf.configureVideoPlayer()
        }
        
        myListButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [unowned self] _ in
            self.toggleTableView(true)
        }
        
        nearMeButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [unowned self] _ in
            self.toggleTableView(false)
        }
        
        /* Data based UI updates */
        
        /**
        Convenience method to add newly sent or accepted invites to home tableView
        
        - parameter updatedInviteList: the updated invite list to work with
        - parameter oppositeList:      either the sent or accepted invitations, used to get an accurate count
        */
        func addInvite(updatedInviteList: AnyObject!, oppositeList: [Invitation]) {
            if let updatedInviteList = updatedInviteList as? [Invitation] {
                if self.viewModel.userInvitations.count < updatedInviteList.count + oppositeList.count {
                    self.viewModel.userInvitations.append(updatedInviteList.last!)
                    self.homeTableView.reloadData()
                }
            }
        }
        
        // The following listeners help reload tableView with new data
        RACObserve(UserDataManager.sharedInstance.currentUser, keyPath: "invitationsSent").subscribeNext({(invitationsSent: AnyObject!) in
            addInvite(invitationsSent, oppositeList: UserDataManager.sharedInstance.currentUser.invitationsAccepted)
        })
        
        RACObserve(UserDataManager.sharedInstance.currentUser, keyPath: "invitationsAccepted").subscribeNext({ (invitationsAccepted: AnyObject!) in
            addInvite(invitationsAccepted, oppositeList: UserDataManager.sharedInstance.currentUser.invitationsSent)
        })
        
        RACObserve(UserDataManager.sharedInstance.currentUser, keyPath: "favorites").subscribeNextAs({ [weak self] (favorites: [FavoritedPOI]) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.homeTableView.reloadData()
        })
    }
    
    /**
    Helper method to switch between tableViews in a smooth way
    
    - parameter showMyList: deteremines whether we are showing MyList or not
    */
    func toggleTableView(showMyList: Bool) {
        self.viewModel.showMyList = showMyList
        self.leadingIndicatorViewConstraint.constant = showMyList ? 0 : self.view.frame.size.width/2
        self.homeTableView.reloadData()
        self.homeTableView.setContentOffset(CGPointZero, animated: true)
        
        // Fixes issue with buttonView getting out of sync in y position
        self.buttonView.setOriginY(fillerTableViewHeader.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        MQALogger.log("Memory warning in Home View", withLevel: MQALogLevelWarning)
    }
    
    // MARK: Video Player Management
    
    /**
    Helper metho to restart video from beginning
    
    - parameter player: the player to restart
    */
    func restartVideo(player: AVPlayerItem) {
        player.seekToTime(kCMTimeZero)
        MQALogger.log("Video Restarted", withLevel: MQALogLevelInfo)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if avPlayer == nil {
            configureVideoPlayer()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()

        if buttonView.superview == nil {
            buttonView.frame = emptyButtonTableViewHeader.frame
            self.view.addSubview(buttonView)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer.pause()
    }
    
    /**
    Sets up AVPlayer and begins playing video
    */
    func configureVideoPlayer() {

        let fileURL = NSURL(fileURLWithPath: viewModel.videoPath)
        avPlayer = AVPlayer(URL: fileURL)
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        avPlayerLayer.frame = avPlayerView.frame
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avPlayerView.layer.insertSublayer(avPlayerLayer, below: overlayView.layer)

        avPlayer.play()
    }
    
    /**
    Method to update video player frame based on offset passed in, moves frame up when offset is positive, increases height of video when scrolling down
    we also move the light blue overlay and buttonView in this method to avoid UI issues
    
    - parameter scrollViewContentOffset: y offset sent from scrollView
    */
    func updateFrameWithScrollViewDidScroll(scrollViewContentOffset : CGFloat){
        
        if (scrollViewContentOffset >= 0) {
            let magicLine = headerVideoHeight - customNavBarHeight

            if(scrollViewContentOffset >= magicLine){
                // Prevents views from going futher than this
                let updatedFrame = CGRectMake(0, -magicLine + yOffset, avPlayerLayer.frame.size.width, headerVideoHeight)
                avPlayerLayer.resizeImmediatly(updatedFrame)
                overlayView.frame = updatedFrame
                buttonView.setOriginY(0)
            }
            else {
                // Moves views up with scroll view
                let updatedFrame = CGRectMake(0, -scrollViewContentOffset + yOffset, avPlayerLayer.frame.size.width, avPlayerLayer.frame.size.height)
                avPlayerLayer.resizeImmediatly(updatedFrame)
                
                // Notice: moving overlayView up so it isn't visible when a user scrolls down
                overlayView.frame = updatedFrame
                
                // If buttonView is at top of screen - status bar height, make it stick to top
                if -scrollViewContentOffset + emptyButtonTableViewHeader.frame.origin.y <= 0 {
                    buttonView.setOriginY(0)
                } else {
                    buttonView.setOriginY(-scrollViewContentOffset + emptyButtonTableViewHeader.frame.origin.y)
                }
                
            }
        }
        else {
            // Increases size of video player
            avPlayerLayer.resizeImmediatly(CGRectMake(0, yOffset, avPlayerLayer.frame.size.width, headerVideoHeight - scrollViewContentOffset))
            buttonView.setOriginY( -scrollViewContentOffset + emptyButtonTableViewHeader.frame.origin.y)
        }
    }
    
    /**
    Method fades and reveals overlays as tableView is scrolled, by modifing the alpha color value
    
    - parameter offset: scrollview offset
    */
    func fadeOverlays(offset: CGFloat) {
        
        if(offset >= 0){
            let magicLine = headerVideoHeight - customNavBarHeight
            
            if(offset >= (magicLine + yOffset)){
                overlayColor = UIColor.venueLightBlue().colorWithAlphaComponent(1.0)
                shadowImageView.alpha = 0.0
            }
            else {
                // Max value we can hit, min is 0
                let max = CGFloat(magicLine + yOffset)
                
                // Calculation to get percentage from 0 to max, in decimals
                let calculatedAlpha = offset / max
                overlayView.backgroundColor = UIColor.venueLightBlue().colorWithAlphaComponent(calculatedAlpha)
                buttonView.backgroundColor = UIColor.venueLightBlue().colorWithAlphaComponent(0.0)
                
                // Instead of moving the shadows frame, we gradually fade it
                shadowImageView.alpha = 1.0 - calculatedAlpha
            }
        } else {
            // Ensures overlay is transparent when image is expanding
            overlayColor = UIColor.venueLightBlue().colorWithAlphaComponent(0.0)
        }
        
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.showMyList ? 5 : 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! POITableViewCell
        viewModel.setupPOICell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Check if selected cell was an Ad, if so, return
        let tableCell = tableView.cellForRowAtIndexPath(indexPath) as! POITableViewCell
        let selectedIndex = homeTableView.indexPathForCell(tableCell)
        if viewModel.displaysAd(selectedIndex!) {
            return
        }
        
        // Otherwise segue to PlaceDetailVC
        let selectedPOI = viewModel.getDisplayedPOI(selectedIndex!)
        let placeDetailViewController = Utils.vcWithNameFromStoryboardWithName("placeDetail", storyboardName: "Places") as! PlaceDetailViewController
        placeDetailViewController.viewModel = PlacesDetailViewModel(poi: selectedPOI)
        self.navigationController?.pushViewController(placeDetailViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Workaround: Odd gap appears when there are no section headers after the first 2
        if !viewModel.dataPresent && section == 3 {
            favoritesHeaderLabel.text = NSLocalizedString("No Items in List", comment: "")
            return favoritesSectionHeader
        } else if section == 3 {
            favoritesHeaderLabel.text = NSLocalizedString("Favorited", comment: "")
        }
        
        switch(section) {
        case 0:
            return fillerTableViewHeader
        case 1:
            return emptyButtonTableViewHeader
        case 2:
            return viewModel.rowsInSection(section) == 0 ? nil : invitationSectionHeader
        case 3:
            return viewModel.rowsInSection(section) == 0 ? nil : favoritesSectionHeader
        case 4:
            return viewModel.rowsInSection(section) == 0 ? nil : completedSectionHeader
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if !viewModel.dataPresent && section == 3 {
            return favoritesSectionHeader.height
        }
        
        switch(section) {
        case 0:
            return fillerTableViewHeader.frame.size.height
        case 1:
            return emptyButtonTableViewHeader.frame.size.height
        case 2:
            return viewModel.rowsInSection(section) == 0 ? 0 : invitationSectionHeader.height
        case 3:
            return viewModel.rowsInSection(section) == 0 ? 0 : favoritesSectionHeader.height
        case 4:
            return viewModel.rowsInSection(section) == 0 ? 0 : completedSectionHeader.height
        default:
            return 0
        }
    }
}

extension HomeViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateFrameWithScrollViewDidScroll(scrollView.contentOffset.y)
        fadeOverlays(scrollView.contentOffset.y)
    }
}
