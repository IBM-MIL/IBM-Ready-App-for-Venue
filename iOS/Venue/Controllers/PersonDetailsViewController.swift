/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// ViewController to display details of a person
class PersonDetailsViewController: UIViewController {
    
    var viewModel: PersonDetailsViewModel?

    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
   
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var croppedMapImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let user = viewModel?.person {
            initialsLabel.text = user.initials
            nameLabel.text = user.name
            profilePicture.image = UIImage(named: user.pictureUrl)
            phoneButton.setTitle(user.phoneNumber, forState: UIControlState.Normal)
        }
        
        // Add gesture recognizer to map view to take you back to Map page
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "mapSelected")
        self.croppedMapImageView.addGestureRecognizer(tapGestureRecognizer)
        self.croppedMapImageView.userInteractionEnabled = true
        
        // Setup nav bar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(nil,forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor.venueLightBlue()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Setup back button as just an arrow
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("backButtonPressed"))
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = backButton
        
        // Setup Reactive bindings
        self.setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        messageButton.layer.cornerRadius = messageButton.frame.height/2
        initialsLabel.layer.cornerRadius = initialsLabel.frame.height/2
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if croppedMapImageView.image == nil {
            // Add cropped image and drop the pin on the map
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let croppedImage = self.viewModel!.croppedMapImage(self.croppedMapImageView.width, height: self.croppedMapImageView.height)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.croppedMapImageView.image  = croppedImage
                    
                    // Get the pin to add to the correct point
                    let pinX = (self.croppedMapImageView.frame.size.width / 2)
                    let pinY = (self.croppedMapImageView.frame.size.height / 2)
                    var pinOffset = CGPoint(x: pinX, y: pinY)
                    pinOffset = self.viewModel!.applyPinOffset(pinOffset)                    
                    let personPin = MyPeopleAnnotation(user: self.viewModel!.person, location: pinOffset, zoomScale: 1.0)
                    personPin.userInteractionEnabled = false
                    self.croppedMapImageView.addSubview(personPin)
                }
            }
        }
    }
    
    func setupBindings() {
        messageButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [weak self] _ in
            if let weakSelf = self {
                if let user = weakSelf.viewModel?.person {
                    let phoneString = user.phoneNumber
                    UIApplication.sharedApplication().openURL(NSURL(string: "sms:\(phoneString)")!)
                }
            }
        }
        phoneButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [weak self] _ in
            if let weakSelf = self {
                if let user = weakSelf.viewModel?.person {
                    let phoneString = user.phoneNumber
                    UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneString)")!)
                }
            }
        }
    }
    
    func mapSelected(){
        guard let tabBarController = self.tabBarController as? TabBarViewController else {
            return
        }
        
        tabBarController.selectMapTab(poi: nil, user: self.viewModel!.person)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
