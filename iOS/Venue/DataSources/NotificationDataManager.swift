/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

/**
*   Asks ManagerHelper to initiate a resource request to get all notifications
    ### There is no Notifications Adapter, data is loaded from Core Data
*/
class NotificationDataManager: NSObject {

    /// Data dictionary to contain results data
    var data: [String : AnyObject]!
    
    /// Callback object to return data to the requesting class, NOTE: if using mfp date, use this callback and parse afterward
    //var callback: (([String: AnyObject])->())!
    var callback: (([Notification])->())!
    var notificationsManHelper: ManagerHelper!
    /// Shared instance variable
    static let sharedInstance: NotificationDataManager = NotificationDataManager()
    
    private override init() {
        super.init()
        
        let url = "/adapters/notifications/getAllNotifications/"
        self.notificationsManHelper = ManagerHelper(URLString: url, delegate: self)
    }
    
    
    /**
    Method to get all notifications using a resource request created by a ManagerHelper
    
    :param: callback callback to send user data
    */
    func getNotifications(callback: ([Notification])->()) {
        self.callback = callback
        
        // Return immediatly because we have data for demo
        let user = UserDataManager.sharedInstance.currentUser
        // Return notifications a user has recieved
        callback(user.notificationsRecieved)
        
        notificationsManHelper.getResource()
    }
    
}

extension NotificationDataManager: HelperDelegate {
    
    /**
    Method to send all notifications from a WLResponse if the resource request is successful
    
    :param: response WLResponse containing data
    */
    func resourceSuccess(response: WLResponse!) {
        print("Notification Success")
        MQALogger.log("Notification Success", withLevel: MQALogLevelInfo)

        // If using MFP data, the follwoing would be used
        /*data = response.getResponseJson() as! [String: AnyObject]
        if data != nil {
            callback(data)
        }*/
    }
    
    /**
    Method to send error message if the resource request fails
    
    :param: error error message for resource request failure
    */
    func resourceFailure(error: String!) {
        print("Expected NotificationDataManager failure with err: \(error)")
        MQALogger.log("Expected NotificationDataManager failure with err: \(error)", withLevel: MQALogLevelError)
        
//        data = ["failure":error]
//        callback(data)
    }
}
