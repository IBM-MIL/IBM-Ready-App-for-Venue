/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  Protocol to provide success and failure messages
*/
@objc protocol HelperDelegate {
  func resourceSuccess(response: WLResponse!)
  func resourceFailure(response: String!)
}

/**
*  Helper class to connect to MFP and initiate a resource request ]
*/
class ManagerHelper: NSObject {
    
    /// HelperDelegate for the ManagerHelper
    weak var delegate: HelperDelegate!

    /// String containing the url to initiate the resource request
    var URLString: String!

    /// Optional params string to pass into Javascript adapters/procedures
    var params: String?

    init(URLString: String!, delegate: HelperDelegate!) {
        self.URLString = URLString
        self.delegate = delegate

        super.init()

        WLClient.sharedInstance().wlConnectWithDelegate(self)
    }
  
    /**
    Method to initiate a connection to the WLClient.sharedInstance()
    */
    func getResource() {
        MQALogger.log("Getting resource at URL: \(URLString)", withLevel: MQALogLevelInfo)
        print("Getting resource at URL: \(URLString)")
        
        let request = WLResourceRequest(URL: NSURL(string: URLString), method: WLHttpMethodGet)
        
        // Set parameters on data call if available
        if let parameters = self.params {
            request.setQueryParameterValue(parameters, forName: "params")
        }
        
        request.sendWithCompletionHandler { (response, error) -> Void in
            
            if(error != nil) { // connection success with error
                self.delegate.resourceFailure("ERROR: \(response.responseText)")
            } else if(response != nil) { //connection success with correct data
                self.delegate.resourceSuccess(response)
            }
        }
    }
    
    /**
    Helper method to add params to an MFP request
    
    - parameter params: params in a string array like so: `['233', 01]`
    */
    func addProcedureParams(params: String) {
        self.params = params
    }
}

extension ManagerHelper: WLDelegate {
    
    /**
    Method called upon successful MFP connection to send data if resource request is successful, or resource failure error message if unsuccessful

    :param: response WLResponse containing user data
    */
    func onSuccess(response: WLResponse!) {
        
        MQALogger.log("Connection SUCCESS!")
    }
  
    /**
    Method called upon failure to connect to MFP, will send errorMsg

    :param: response WLFailResponse containing failure response
    */
    func onFailure(response: WLFailResponse!) {
        
        MQALogger.log("Connection FAILURE!")
        self.delegate.resourceFailure("no connection")
    }
}