/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// View model to handle grouping users by the inital of their last name, displaying users, and searches
class PeopleListViewModel: NSObject {
    
    var allUsers = [User]()
    var displayedUserSections = [UserKeyItem]()
    
    override init() {
        super.init()
        UserDataManager.sharedInstance.getUsers(UserDataManager.sharedInstance.currentUser.group.id) { [weak self] (users: [User]) in
            guard let strongSelf = self else {
                return
            }
            
            // Show all users except the current user
            let currentUser = UserDataManager.sharedInstance.currentUser
            strongSelf.allUsers = users.filter({$0.id != currentUser.id})
        }
        displayedUserSections = parseUsersIntoSections(allUsers)
    }
    
    /**
    Divides users into sections based on the first letter of their last name
    
    :parameter: array of users to be displayed
    :prerequisites: users must be alphabetically sorted by last name
    */
    func parseUsersIntoSections(users: [User]) -> [UserKeyItem] {
        var currentIndex = -1
        var results = [UserKeyItem]()
        for user in users {
            if results.count == 0 || results[currentIndex].key != user.last_name[0] {
                // Key is first letter of last name, the user is the first in an array of values
                results.append(UserKeyItem(key: user.last_name[0], user: user))
                currentIndex++
            }
            else {
                // append current user to value array
                results[currentIndex].users.append(user)
            }
        }
        return results
    }
    
    /**
    Sets up person cell to display person information and divider if not the end of section
    */
    func setUpPersonCell(personCell: PeopleTableViewCell, indexPath: NSIndexPath) {
        let person = displayedUserSections[indexPath.section].users[indexPath.row]
        
        personCell.nameLabel.text = person.name
        personCell.imagePlaceholder.text = person.initials
        
        if person.pictureUrl != "" {
            personCell.profileImage.image = UIImage(named: person.pictureUrl)
        }
        personCell.selectedImageView.hidden = true
        
        personCell.user  = person
        
        if indexPath.row == displayedUserSections[indexPath.section].users.count - 1 {
            personCell.dividerView.hidden = true
        }
        else {
            personCell.dividerView.hidden = false
        }
    }
    
    /**
    Searches through all users and sets the users to be displayed that have a prefix of the search query
    
    :parameter: the query to be compared against
    */
    func filterPeople(searchQuery: String) {
        let searchQuery = searchQuery.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if searchQuery != "" {
            var results = [User]()
            
            for person in allUsers {
                if person.first_name.lowercaseString.hasPrefix(searchQuery) || person.last_name.lowercaseString.hasPrefix(searchQuery) || person.name.lowercaseString.hasPrefix(searchQuery) {
                    results.append(person)
                }
            }
            
            displayedUserSections = parseUsersIntoSections(results)
        }
        else {
            displayedUserSections = parseUsersIntoSections(allUsers)
        }
    }

}
