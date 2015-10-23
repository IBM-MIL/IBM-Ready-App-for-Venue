/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var leaderboardContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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

}

