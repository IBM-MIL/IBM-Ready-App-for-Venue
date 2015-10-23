/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import CoreData
import CoreSpotlight
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let broadcastManager = BroadcastManager()
    
    /// Computed property to evaluate if we are using an iOS simulator or physical device based on architecture in play
    var usingSimulator: Bool {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return true
        #else
            return false
        #endif
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        configureExternalServices()
        
        // Events that trigger a permissions request.
        if !usingSimulator {
            // Start broadcasting bluetooth
            broadcastManager.start()
            // Request ability to send notifications
            let alertSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
            application.registerUserNotificationSettings(alertSettings)
        }
        
        // Fetch Application Data from json file
        let applicationDataManager = ApplicationDataManager.sharedInstance
        applicationDataManager.saveJsonFileToCoreData()
        
        // Configure navigationBar UI for most of app
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.venueLightBlue()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.latoBold(17.0)]
        UINavigationBar.appearance().translucent = false
        
        // Set the settings to allow music to play when using the app
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Don't really care if this fails...
        }
        
        return true
    }
    
    func configureExternalServices() {
        
        // Set the logger level for MFP
        OCLogger.setLevel(OCLogger_FATAL)
        
        var isDevelopment = true
        // Read configurations from the Config.plist.
        let configurationPath = NSBundle.mainBundle().pathForResource("Config", ofType: "plist")
        if((configurationPath) != nil){
            let configuration = NSDictionary(contentsOfFile: configurationPath!) as! [String: AnyObject]!
            
            if let isDev = configuration["isDevelopment"] as? Bool {
                isDevelopment = isDev
            }
        }
        
        //Set the SDK mode Market vs QA for Production and Pre-Production
        #if Debug
            // Do nothing
        #else
            if isDevelopment {
                MQALogger.settings().mode = MQAMode.QA
            } else {
                MQALogger.settings().mode = MQAMode.Market
            }
            
            // Starts a quality assurance session using a key and QA mode
            MQALogger.startNewSessionWithApplicationKey("1g37201fca13b4abd599252245edc219c83791350ag0g1g2b710c82")
        #endif
        
        // Enables the quality assurance application crash reporting
        NSSetUncaughtExceptionHandler(exceptionHandlerPointer)
        
        // Fix for MQA no root view controller error (only occurs when not connected to the internet)
        let windows = UIApplication.sharedApplication().windows
        for window in windows {
            if window.rootViewController == nil {
                window.rootViewController = UIViewController()
            }
        }
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /**
    This handles what happens when opening the app from iOS 9 Search index. We want to go to the Map page with the POI selected
    */
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            if userActivity.activityType == CSSearchableItemActionType {
                if let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    
                    guard let tabBarController = self.window?.rootViewController as? TabBarViewController else {
                        return false
                    }
            
                    PoiDataManager.sharedInstance.getPOIData() { (poiData: [POI]) in
                        for poi in poiData {
                            if poi.name == identifier {
                                tabBarController.selectMapTab(poi: poi, user: nil)
                            }
                        }
                    }
                    
                    return true
                }
            }
        }
        return false
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ibm.cio.be.Venue" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Venue", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Venue.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        let optionsDictionary = ["NSMigratePersistentStoresAutomaticallyOption" : NSNumber(bool: true), "NSInferMappingModelAutomaticallyOption" : NSNumber(bool: true)]
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: optionsDictionary)
        } catch let error as NSError {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        } catch {}
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }


}

