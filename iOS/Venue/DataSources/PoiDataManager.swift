/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// Asks ManagerHelper to initiate a resource request to get all POIs
class PoiDataManager: NSObject {

    /// Data dictionary to contain results data
    var data: [String : AnyObject]!
    /// Callback object to return data to the requesting class, NOTE: if using mfp date, use this callback and parse afterward
    //var callback: (([String: AnyObject])->())!
    var callback: (([POI])->())!
    var poiManHelper: ManagerHelper!
    /// Shared instance variable
    static let sharedInstance: PoiDataManager = PoiDataManager()

    private override init() {
        super.init()

        let url = "/adapters/poisAdapter/getAllPOIs/"
        self.poiManHelper = ManagerHelper(URLString: url, delegate: self)
        
    }
    
    
    /**
    Method to get Point of Interest data using a resource request created by a ManagerHelper
    
    :param: callback callback to send user data
    */
    func getPOIData(callback: ([POI])->()) {
        self.callback = callback
        
        // Return immediately because we have data for demo
        let appDataManager = ApplicationDataManager.sharedInstance
        let pointsOfInterestArray = appDataManager.loadPOIsFromCoreData()
        self.callback(pointsOfInterestArray)

        poiManHelper.getResource()
    }
}

extension PoiDataManager: HelperDelegate {
    
    /**
    Method to send POI data from a WLResponse if the resource request is successful
    
    :param: response WLResponse containing data
    */
    func resourceSuccess(response: WLResponse!) {
        print("POI Data Success with response: \(response.responseText)")
        MQALogger.log("POI Data Success with response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        // If using MFP data, the following would be used
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
        print("PoiDataManager failure with err: \(error)")
        MQALogger.log("PoiDataManager failure with err: \(error)", withLevel: MQALogLevelError)
        
//        data = ["failure":error]
//        callback(data)
    }
}
