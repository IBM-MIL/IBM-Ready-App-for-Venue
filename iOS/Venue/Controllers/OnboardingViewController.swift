/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

/// ViewController to display the onboarding tutorial
class OnboardingViewController: VenueUIViewController {
    @IBOutlet weak var getStartedView: UIView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    var pageViewController: UIPageViewController!
    var pageContentArray = [OnboardingContentViewController]()
    
    let NUMBER_PAGES = 5
    override func viewDidLoad() {
        createPageContentViewControllers()
        createPageViewController()
        setupPageControl()
        
        setupBindings()
        getStartedView.hidden = true
        
        super.viewDidLoad()
    }
    
    /**
    Reactive bindng to transition away from tutorial when clicking on skip button or getting started button
    */
    func setupBindings() {
        skipButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext({[unowned self] _ in
            self.transitionToMainScreen()
            })
        
        getStartedButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext({[unowned self] _ in
            self.transitionToMainScreen()
            })
    }
    
    /**
    Instantiates and sets up page view controller and adds it as a subview
    */
    private func createPageViewController() {
        pageViewController = storyboard!.instantiateViewControllerWithIdentifier("onboardingPageViewController") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        pageViewController.setViewControllers([pageContentArray[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: UIScreen.mainScreen().bounds.size.height * 0.9)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    /**
    Instantiates and sets up OnboardingContentViewControllers and adds them to pageContentArray
    */
    private func createPageContentViewControllers() {
        for i in 0...NUMBER_PAGES {
            let pageContentViewController = storyboard!.instantiateViewControllerWithIdentifier("onboardingPageContent") as! OnboardingContentViewController
            pageContentArray.append(pageContentViewController)
            pageContentArray[i].itemIndex = i
            setContent(pageContentViewController)
        }
    }
    
    /**
    Configures page control appearance
    */
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.venueLightBlue()
        appearance.currentPageIndicatorTintColor = UIColor.venueRed()
    }
    
    private func transitionToMainScreen() {
        NSNotificationCenter.defaultCenter().postNotificationName("OnboardingDismissed", object: nil)
        NSUserDefaults.standardUserDefaults().setValue(false, forKey: "firstStartup")
        self.dismissViewControllerAnimated(true, completion: {})
    }
}

// MARK: - UIPageViewController methods
extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    /**
    Shows next view in pageContent array unless it is at the end
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let contentViewController = viewController as? OnboardingContentViewController {
            if contentViewController.itemIndex == NUMBER_PAGES - 1 {
                return nil
            }
            else {
                return pageContentArray[contentViewController.itemIndex + 1]
            }
        }
        return nil
    }
    
    /**
    Shows previous view in pageContent array unless it is at the beginning
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let contentViewController = viewController as? OnboardingContentViewController {
            if contentViewController.itemIndex == 0 {
                return nil
            }
            else {
                return pageContentArray[contentViewController.itemIndex - 1]
            }
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return NUMBER_PAGES
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    /**
    Shows "Get Started" banner if the transition to the last page is completed
    */
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            if let pageContentViewController = pageViewController.viewControllers?[0] as? OnboardingContentViewController {
                if pageContentViewController.itemIndex == NUMBER_PAGES - 1 {
                    getStartedView.hidden = false
                }
            }
        }
    }
    
    /**
    Sets content in tutorial screen based on the controller's index
    */
    func setContent(contentViewController:OnboardingContentViewController) {
        switch(contentViewController.itemIndex) {
        case 0:
            contentViewController.titleText = NSLocalizedString("Showcase Intelligent, Location-Based Services", comment: "")
            contentViewController.imageName = "onboarding_2"
            contentViewController.descriptionText = NSLocalizedString("Presence Insights enables a tailored user experience. Park guests can view their location, people, and places of interest.", comment: "")
            return
        case 1:
            contentViewController.titleText = NSLocalizedString("Multi-Channel Experience", comment: "")
            contentViewController.imageName = "onboarding_5"
            contentViewController.descriptionText = NSLocalizedString("Visitors can use large displays as a natural extension of their phones to enhance mapping, offers, and engagement.", comment: "")
            return
        case 2:
            contentViewController.titleText = NSLocalizedString("Gamification & Rewards", comment: "")
            contentViewController.imageName = "onboarding_4"
            contentViewController.descriptionText = NSLocalizedString("Challenges use the Gamification service, running on IBM Bluemix, to engage visitors and influence behavior.", comment: "")
            return
        case 3:
            contentViewController.titleText = NSLocalizedString("Let’s Get Social!", comment: "")
            contentViewController.imageName = "onboarding_3"
            contentViewController.descriptionText = NSLocalizedString("Visiting a venue is a social experience. Users can generate messages and invite their friends to attractions from within the app.", comment: "")
            return
        case 4:
            contentViewController.titleText = NSLocalizedString("Add your Favorite Attractions to Your List", comment: "")
            contentViewController.imageName = "onboarding_1"
            contentViewController.descriptionText = NSLocalizedString("Recieve automated wait time alerts, ride status, and proximity alerts for favorited attractions.", comment: "")
            return
        default:
            return
            
        }
    }
}