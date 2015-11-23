/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
//import PresenceInsightsSDK

/// Class to handle the PresenceInsights setup and info requests
class PresenceInsightsManager: NSObject {
    
//    private var presenceInsightsAdapter: PIAdapter!
    private var username: String!
    private var password: String!
    private var tenant: String!
    private var org: String!
    //    private var site: String!
    //    private var floor: String!
//    private var device: PIDevice!
    
    class var sharedInstance: PresenceInsightsManager {
        struct Static {
            static let instance: PresenceInsightsManager = PresenceInsightsManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        initPI()
    }

    private func initPI() {
        var piConfig: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("PIConfig", ofType: "plist") {
            piConfig = NSDictionary(contentsOfFile: path)
        }
        
        if let config = piConfig {
            username = config.objectForKey("username") as! String
            password = config.objectForKey("password") as! String
            tenant = config.objectForKey("tenant") as! String
            org = config.objectForKey("org") as! String
            
//            presenceInsightsAdapter = PIAdapter(tenant: tenant, org: org, username: username, password: password)
//            presenceInsightsAdapter.enableLogging()
        }
    }
    
    /**
    Use this function to register / update device with Presence Insights
    */
    func registerDevice() {
//        device = PIDevice(name: "Current User")
//        device.code = "Test Code!"
//        device.type = "Internal"
//        device.registered = true
//        device.addToUnencryptedDataObject("some location", key: "location")
//        device.addToUnencryptedDataObject("iOS", key: "phoneOS")
//        device.addToUnencryptedDataObject("Vortext", key: "appName")
//
//        presenceInsightsAdapter.registerDevice(device, callback: {newDevice, error in
//            if (error != nil) {
//                MQALogger.log("Error registering device with Presence Insights", withLevel: MQALogLevelWarning)
//            } else {
//                self.device = newDevice
//            }
//        })
    }
    
    /**
    Queries presence insights for the device associated with a user to get their location
    
    - parameter user:     The user to query
    - parameter callback: The function to pass the user's location to
    */
    func getUserLocation(user: User, callback: (CGPoint) -> ()) {
        
        // For demo purposes, we are just going to return the hardcoded data:
        callback(CGPoint(x: user.currentLocationX, y: user.currentLocationY))
        
        // In real-world, we would query PI to get the location
//        presenceInsightsAdapter.getDeviceByCode(user.deviceId) { returnedDevice, error in
//            if error == nil {
//                // Use data from the device returned from Presence Insights to determine user's location
//            }
//        }
    }
}
