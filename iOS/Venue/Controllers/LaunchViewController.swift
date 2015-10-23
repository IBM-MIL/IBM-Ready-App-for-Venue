/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import ReactiveCocoa

/// ViewController to show while waiting for Core Data to load
class LaunchViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let applicationDataManager = ApplicationDataManager.sharedInstance
        if(applicationDataManager.isDoneLoading) {
            checkForOnboarding()
        }
        else {
            RACObserve(applicationDataManager, keyPath: "isDoneLoading").subscribeNext({ [weak self] (isDoneLoading: AnyObject!) in
                if let isDone = isDoneLoading as? Bool {
                    if isDone && self != nil{
                        self!.checkForOnboarding()
                    }
                }
            })
        }
    }
    
    func checkForOnboarding() {

        if let firstStartup = NSUserDefaults.standardUserDefaults().objectForKey("firstStartup") as? Bool {
            if !firstStartup {
                transitionToMainScreen()
                return
            } else {
                displayOnboardingModal()
            }
        } else {
            NSUserDefaults.standardUserDefaults().setValue(true, forKey: "firstStartup")
        }
        
        displayOnboardingModal()
    }
    
    func displayOnboardingModal() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let tutorialViewController = mainStoryboard.instantiateViewControllerWithIdentifier("onboardingViewController")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "transitionToMainScreen", name: "OnboardingDismissed", object: nil)
        
        presentViewController(tutorialViewController, animated: true, completion: {})
        
    }
    
    func transitionToMainScreen() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "OnboardingDismissed", object: nil)
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let mainViewController = mainStoryboard.instantiateViewControllerWithIdentifier("tabBarViewController")
        UIApplication.sharedApplication().delegate!.window!!.rootViewController = mainViewController
    }
}