/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// ViewController to show who has been inivited to a place
class PlaceInviteViewController: VenueUIViewController {
    
    var viewModel: PlaceInviteViewModel!
    
    @IBOutlet weak var avatarCollectionView: UICollectionView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomBar.hidden = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // set navigation bar to be light blue
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
        
        // Remove 1px shadow under nav bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func popVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showBottomBar() {
        bottomBar.hidden = false
        // move container up so bottom bar does not block table
        containerViewBottomConstraint.constant = bottomBar.frame.height
    }
    
    func hideBottomBar() {
        bottomBar.hidden = true
        // move container back down
        containerViewBottomConstraint.constant = 0
    }
    
    
    /**
    Segue preparation for selection of date picker and embedment of the peopleListViewController
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // sends the selected user and the poi to the date picker
        if let datePickerViewController = segue.destinationViewController as? DatePickerViewController {
            datePickerViewController.selectedUsers = viewModel.selectedUsers
            datePickerViewController.location = viewModel.location
        }
        else if let storyboardViewController = segue.destinationViewController as? RBStoryboardLink {
            // segeue triggered in embeded
            if let peopleListViewController = storyboardViewController.scene as? PeopleListViewController {
                // sets people list delegate to self so PeopleListDelegate methods get called
                peopleListViewController.delegate = self
            }
        }
    }
    
}

// MARK: - PeopleListDelegate Implementation
extension PlaceInviteViewController: PeopleListDelegate {
    /**
    Handles selection of row by toggling selction icon and mananging the avatar collection on the bottom bar
    */
    func didSelectRow(tableView: UITableView, indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PeopleTableViewCell
        if !cell.isSelectedForInvite {
            viewModel.markSelectedAndUpdateCollection(cell, indexPath: indexPath, avatarCollectionView: avatarCollectionView)
        }
        else {
            viewModel.markDeselectedAndUpdateCollection(cell, indexPath: indexPath, avatarCollectionView: avatarCollectionView)
        }
        
        if viewModel.selectedUsers.count > 0 && bottomBar.hidden == true {
            showBottomBar()
        }
        else if viewModel.selectedUsers.count == 0 && bottomBar.hidden == false {
            hideBottomBar()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    /**
    Makes sure that peopleTableViewCell is properly marked if selected
    */
    func additionalSetupForCell(cell: PeopleTableViewCell) {
        viewModel.setupPeopleTableViewCell(cell)
    }
}

// MARK: - UICollectionView Methods
extension PlaceInviteViewController :  UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectedUsers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("avatarCell", forIndexPath: indexPath) as! AvatarImageCollectionViewCell
        return viewModel.setupAvatarImageCollectionCell(cell, row: indexPath.row)
        
    }
}
