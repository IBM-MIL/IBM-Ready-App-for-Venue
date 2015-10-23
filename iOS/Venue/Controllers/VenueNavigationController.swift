/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// UINavigationController to help solve panning transition issues freezing the app
class VenueNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        weak var weakSelf = self

        if (self.respondsToSelector("interactivePopGestureRecognizer")) {
            self.interactivePopGestureRecognizer!.delegate = weakSelf
            self.delegate = weakSelf
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        if self.respondsToSelector("interactivePopGestureRecognizer") {
            self.interactivePopGestureRecognizer?.enabled = false
            super.pushViewController(viewController, animated: animated)
        }
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        
        if viewController == self.viewControllers.first {
            if self.respondsToSelector("interactivePopGestureRecognizer") {
                self.interactivePopGestureRecognizer?.enabled = false
            }
        } else {
            if self.respondsToSelector("interactivePopGestureRecognizer") {
                self.interactivePopGestureRecognizer?.enabled = true
            }
        }
 
    }

}
