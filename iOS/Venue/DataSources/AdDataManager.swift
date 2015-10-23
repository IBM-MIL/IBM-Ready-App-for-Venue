/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

/**
*   Asks ManagerHelper to initiate a resource request to get Ad data
*/
class AdDataManager: NSObject {
    
    /// Data dictionary to contain results data
    var data: [String : AnyObject]!
    
    /// Callback object to return data to the requesting class, NOTE: if using mfp date, use this callback and parse afterward
    //var callback: (([String: AnyObject])->())!
    var callback: (([Ad])->())!
    var adsManHelper: ManagerHelper!
    /// Shared instance variable
    static let sharedInstance: AdDataManager = AdDataManager()
    
    private override init() {
        super.init()
        
        let url = "/adapters/ads/getAllAds/"
        self.adsManHelper = ManagerHelper(URLString: url, delegate: self)
        
    }
    
    /**
    Method to get all users using a resource request created by a ManagerHelper
    
    :param: callback callback to send user data
    */
    func getAdData(callback: ([Ad])->()) {
        self.callback = callback
        
        // Return immediatly because we have data for demo
        let dataManager = ApplicationDataManager.sharedInstance
        let ads = dataManager.loadAdsFromCoreData()
        self.callback(ads)
    
        adsManHelper.getResource()
    }
    
}

extension AdDataManager: HelperDelegate {
    /**
    Method to send Ads data from a WLResponse if the resource request is successful
    
    :param: response WLResponse containing data
    */
    func resourceSuccess(response: WLResponse!) {
        print("Ad Success with response: \(response.responseText)")
        MQALogger.log("Ad Success with response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
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
        print("Expected AdDataManager Failure with err: \(error)")
        MQALogger.log("Expected AdDataManager Failure with err: \(error)", withLevel: MQALogLevelError)
        
//        data = ["failure":error]
//        callback(data)
    }
}