/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

/**
*   Asks ManagerHelper to initiate a resource request to get Challanges data
*/
class ChallengeDataManager: NSObject {
    
    /// Data dictionary to contain results data
    var data: [String : AnyObject]!
    /// Callback object to return data to the requesting class, NOTE: if using mfp date, use this callback and parse afterward
    //var callback: (([String: AnyObject])->())!
    var callback: (([Challenge])->())!
    var challengesManHelper: ManagerHelper!
    /// Shared instance variable
    static let sharedInstance: ChallengeDataManager = ChallengeDataManager()
    
    private override init() {
        super.init()
        
        let url = "/adapters/gamificationAdapter/getBadges/"
        self.challengesManHelper = ManagerHelper(URLString: url, delegate: self)
    }
    
    /**
    Method to get all badges/achievements using a resource request created by a ManagerHelper
    
    :param: callback callback to send user data
    */
    func getChallenges(callback: ([Challenge])->()) {
        self.callback = callback
        
        // Return immediatly because we have data for demo
        let dataManager = ApplicationDataManager.sharedInstance
        let challenges = dataManager.loadChallengesFromCoreData()
        self.callback(challenges)
    
        challengesManHelper.getResource()
    }
    
}

extension ChallengeDataManager: HelperDelegate {
    /**
    Method to send list of challanges/achievements from a WLResponse if the resource request is successful
    
    :param: response WLResponse containing data
    */
    func resourceSuccess(response: WLResponse!) {
        print("ChallengeDataManager Success: \(response.responseText)")
        MQALogger.log("ChallengeDataManager Achievement Success: \(response.responseText)", withLevel: MQALogLevelInfo)
        
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
        print("ChallengeDataManager Failure! with err: \(error)")
        MQALogger.log("ChallengeDataManager Failure! with err: \(error)", withLevel: MQALogLevelError)
        
//        data = ["failure":error]
//        callback(data)
    }
}