/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

/// Class that represents a group of users with the same inital of their last name
class UserKeyItem {
    let key: Character
    var users: [User]
    
    init(key: Character, user: User) {
        self.key = key
        users = [user]
    }
}