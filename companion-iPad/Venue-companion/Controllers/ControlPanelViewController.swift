/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class ControlPanelViewController: UIViewController {
    
    let bluetoothManager = (UIApplication.sharedApplication().delegate as! AppDelegate).bluetoothManager

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        #if !Debug
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: NSStringFromClass(self.dynamicType))
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressOfferButton(sender: AnyObject) {
        print("pressed offer")
        bluetoothManager.sendDataFromString("offer")
    }
    
    @IBAction func didPressWeatherButton(sender: AnyObject) {
        bluetoothManager.sendDataFromString("weather")
    }
    
    @IBAction func didPressWaitTimeButton(sender: AnyObject) {
        bluetoothManager.sendDataFromString("waittime")
    }
    
    @IBAction func didPressInviteButton(sender: AnyObject) {
        bluetoothManager.sendDataFromString("invite")
    }
    
    @IBAction func didPressReminderButton(sender: AnyObject) {
        bluetoothManager.sendDataFromString("reminder")
    }
    
    @IBAction func didPressBadgeButton(sender: AnyObject) {
        bluetoothManager.sendDataFromString("badge")
    }

    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
