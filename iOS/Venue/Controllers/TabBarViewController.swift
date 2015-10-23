/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// Custom Tab bar to handle minimal UI customization and tab navigation
class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    private let mapTabIndex = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        tabBar.tintColor = UIColor.venueRed()
        // Remove 1px bar on top of tabBar with the following
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        
        // Move tab bar item text up so it's not so close to the bottom of the screen
        for tabItem in tabBar.items! {
            tabItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    Evaluates whether map tab is the currently select tab
    
    - returns: bool with result
    */
    func mapTabCurrentlySelected() -> Bool {
        return self.selectedIndex == mapTabIndex
    }
    
    /**
    Quick way to open map tab and dispaly a particular POI
    
    - parameter poi:  poi to display
    - parameter user: user object to show if no POI
    */
    func selectMapTab(poi poi: POI?, user: User?) {
        if let navController = self.viewControllers![mapTabIndex] as? UINavigationController {
            if let placesVC = navController.viewControllers[0] as? PlacesViewController {
                if let poi = poi {
                    placesVC.initialPOI = poi
                    if self.selectedIndex == mapTabIndex {
                        placesVC.checkInitialPOI()
                    }
                } else if let user = user {
                    placesVC.initialUser = user
                }
            }
            navController.popToRootViewControllerAnimated(true)
        }
        
        self.selectedIndex = mapTabIndex
    }
}
