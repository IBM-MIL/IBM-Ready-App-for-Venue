/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

/**
*   Asks ManagerHelper to initiate a resource request to get authorized User data
*/
class UserDataManager: NSObject {
    
    var oneUserCallback: ((User)->())!
    /// Callback object to return data to the requesting class, NOTE: if using mfp date, use this callback and parse afterward
    var callback: (([User])->())!
    /// Data dictionary to contain results data
    var data: [String : AnyObject]!
    var singleUserManHelper: ManagerHelper!
    var usersManHelper: ManagerHelper!
    /// Shared instance variable for access the currentUser
    static let sharedInstance: UserDataManager = UserDataManager()

    
    var currentUser = User()
    
    private override init() {
        
        super.init()
        
        var url = "/adapters/usersAdapter/getGroupLeaderboard/"
        self.usersManHelper = ManagerHelper(URLString: url, delegate: self)
        
        url = "/adapters/usersAdapter/getUser/"
        self.singleUserManHelper = ManagerHelper(URLString: url, delegate: self)
        
        // Set current user for demo, would have info after a login normally
        self.getUser(0) { (user: User) in
            self.currentUser = user
        }
    }
    
    /**
    Method to get a user from the backend using an ID
    
    - parameter id:       the ID of the User we want
    - parameter callback: callback to send user object to
    */
    func getUser(id: Int, callback: ((User)->())) {
        self.oneUserCallback = callback
        
        let allUsers = ApplicationDataManager.sharedInstance.loadUsersFromCoreData()
        let userEmail = CurrentUserDemoSettings.getCurrentUserEmail()
        
        // Return immediatly because we have data for demo
        if let firstUser = allUsers.filter({ $0.email == userEmail }).first {
            self.oneUserCallback(firstUser)
        }
        
        singleUserManHelper.addProcedureParams("['\(id)']")
        singleUserManHelper.getResource()
    }
    
    /**
    Method to get user data using a resource request created by a ManagerHelper
    
    :param: callback callback to send user data
    */
    func getUsers(groupID: Int, callback: ([User])->()) {
        self.callback = callback
        
        // Return immediatly because we have data for demo
        let dataManager = ApplicationDataManager.sharedInstance
        let leaders = dataManager.loadUsersFromCoreData()
        self.callback(leaders)
        
        usersManHelper.addProcedureParams("['\(groupID)']")
        usersManHelper.getResource()
    }
    
    /**
    Method finds the user that sent out a specific invitation
    
    - parameter ID:       invitation ID to find
    - parameter callback: callback to return the inviter `User`
    */
    func getHostForInvitation(ID: Int, callback: (User?)->()) {
        
        // We don't have an invitation data manager, so I will get invites through users
        self.getUsers(self.currentUser.group.id) { (users: [User]) in
            for user in users {
                let reduced = user.invitationsSent.filter({ $0.id == ID })
                if reduced.count == 1 {
                    callback(user)
                    return
                }
            }
            callback(nil)
        }
    }
    
}

extension UserDataManager: HelperDelegate {
    /**
    Method to send user data from a WLResponse if the resource request is successful
    
    :param: response WLResponse containing data
    */
    func resourceSuccess(response: WLResponse!) {
        print("User Data Success with response: \(response.responseText)")
        MQALogger.log("User Data Success with response: \(response.responseText)", withLevel: MQALogLevelInfo)
        
        // If using MFP data, the follwoing would be used
        // You would need to check if this was a response for a single user or for the list of all users
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
        print("UserDataManager Failure! with err: \(error)")
        MQALogger.log("UserDataManager failure with err: \(error)", withLevel: MQALogLevelError)
        
//        data = ["failure":error]
//        callback(data)
    }
}