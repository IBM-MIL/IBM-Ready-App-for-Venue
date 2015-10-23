/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class ControlPanelViewController: UIViewController {

    @IBOutlet weak var offerButton: UIButton!
    @IBOutlet weak var weatherButton: UIButton!
    @IBOutlet weak var waitTimeButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var badgeButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentViewWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressTutorialButton(sender: AnyObject) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let tutorialViewController = mainStoryboard.instantiateViewControllerWithIdentifier("onboardingViewController")
        
        presentViewController(tutorialViewController, animated: true, completion: {})
        
    }
    
    @IBAction func didPressButton(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

}

extension ControlPanelViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("controlCell") as? ControlTableViewCell {
            
            switch indexPath.row {
            case 0:
                if let image = UIImage(named: "button_offers") {
                    cell.controlImage.image = image
                    cell.controlLabel.text = "Context-Driven Offer"
                }
                break
            case 1:
                if let image = UIImage(named: "button_weather") {
                    cell.controlImage.image = image
                    cell.controlLabel.text = "Inclement Weather Alert"
                }
                break
            case 2:
                if let image = UIImage(named: "button_waittime") {
                    cell.controlImage.image = image
                    cell.controlLabel.text = "Queue Wait-Time Alert"
                }
                break
            case 3:
                if let image = UIImage(named: "button_reminder") {
                    cell.controlImage.image = image
                    cell.controlLabel.text = "Planned Event Reminder"
                }
                break
            case 4:
                if let image = UIImage(named: "button_badges") {
                    cell.controlImage.image = image
                    cell.controlLabel.text = "Gamification Badge Earned"
                }
                break
            case 5:
                if let image = UIImage(named: "button_invitation") {
                    cell.controlImage.image = image
                    cell.controlLabel.text = "Receive an Invitation"
                }
                break
            default:
                break
            }
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.height/9
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case 0:
            DemoManager.sendOffer()
            break
        case 1:
            DemoManager.weatherAlert()
            break
        case 2:
            DemoManager.waitTimeAlert()
            break
        case 3:
            DemoManager.sendReminder()
            break
        case 4:
            DemoManager.unlockBadge()
            break
        case 5:
            DemoManager.sendInvite()
            break
        default:
            break
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}
