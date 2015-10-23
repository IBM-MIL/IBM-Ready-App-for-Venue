/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// Helper class to easily retrieve certain user data
class CurrentUserDemoSettings: NSObject {

    /**
    Method to simulate already having a reference to a user's email, by pulling it out of a plist
    
    - returns: email as a String
    */
    class func getCurrentUserEmail() -> String {
        var config: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("DemoSettings", ofType: "plist") {
            config = NSDictionary(contentsOfFile: path)
        }
        
        if let config = config {
            return config.objectForKey("User Email") as! String
        }
        
        return ""
    }
    
    /**
    Method to simulate already having a reference to a user's password, by pulling it out of a plist
    
    - returns: password as a String
    */
    class func getCurrentUserPassword() -> String {
        var config: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("DemoSettings", ofType: "plist") {
            config = NSDictionary(contentsOfFile: path)
        }
        
        if let config = config {
            return config.objectForKey("User Password") as! String
        }
        
        return ""
    }
}
