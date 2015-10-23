/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

/// ViewController to show the date picker for a place invite
class DatePickerViewController : VenueUIViewController {
    var selectedUsers = [User]()
    var location : POI!
    @IBOutlet weak var bottomNavigationButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    /**
    Style native navigationBar to avoid any UI issues
    */
    func setupNavigationBar() {
       
        // Setup back button as just an arrow
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("popVC"))
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = backButton
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonPressed")
        navigationItem.rightBarButtonItem = cancelButton
        
        // Remove 1px shadow under nav bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func popVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func cancelButtonPressed() {
        guard let placeDetailController = self.navigationController?.viewControllers[self.navigationController!.viewControllers.count - 3] as? PlaceDetailViewController else {
            return
        }
        navigationController?.popToViewController(placeDetailController, animated: true)
    }
    
    /**
    Reactive bindng to "send invite" button: creates the invititation and banner message, pops back to PlaceDetail screen
    */
    func setupBindings() {
        bottomNavigationButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext({[unowned self](_: AnyObject!) -> Void in
            let applicationDataManager = ApplicationDataManager.sharedInstance
            applicationDataManager.createInvitation(self.datePicker.date, location: self.location, recipients: self.selectedUsers)
            // checks to make sure place detail controller is two below on the stack
            guard let placeDetailController = self.navigationController?.viewControllers[self.navigationController!.viewControllers.count - 3] as? PlaceDetailViewController else {
                return
            }
            let dateFormatter = NSDateFormatter()
            // format is hour:minute with the 'j' used to allow 24 hour clock displays
            dateFormatter.setLocalizedDateFormatFromTemplate("j:mm")
            let invitationPrefix = self.selectedUsers.count > 1 ? "Invitations" : "Invitation"
            let inviteString = NSLocalizedString(invitationPrefix + " to " + self.location.name + " at " + dateFormatter.stringFromDate(self.datePicker.date) + " have been sent",comment: "")
            // sets boolean and message in place detail controller so place detail properally displays notificiation banner
            placeDetailController.inviteSent = true
            placeDetailController.inviteString = inviteString
            self.navigationController?.popToViewController(placeDetailController, animated: true)
            })
    }
}

// MARK: - UICollectionView Methods
extension DatePickerViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("avatarCell", forIndexPath: indexPath) as! AvatarImageCollectionViewCell
        
        if selectedUsers[indexPath.row].pictureUrl != "" {
            cell.avatarImageView.image = UIImage(named: selectedUsers[indexPath.row].pictureUrl)
        }
        cell.avatarPlaceholderLabel.text = selectedUsers[indexPath.row].initials
        
        return cell
    }
}