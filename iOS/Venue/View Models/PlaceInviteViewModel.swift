/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import ReactiveCocoa

/// View model to handle keeping track of users selected for a place invite
class PlaceInviteViewModel: NSObject {
    let location: POI
    var selectedUsers = [User]()
    
    init(location: POI) {
        self.location = location
        super.init()
    }
    
    func setupPeopleTableViewCell(cell: PeopleTableViewCell) {
        let person = cell.user
        
        if isSelectedWithId(person.id) {
            cell.selectedImageView.hidden = false
            cell.isSelectedForInvite = true
        }
        else {
            cell.selectedImageView.hidden = true
            cell.isSelectedForInvite = false
        }
    }
    
    func setupAvatarImageCollectionCell(cell: AvatarImageCollectionViewCell, row: Int) -> AvatarImageCollectionViewCell {
        let person = selectedUsers[row]
        
        if person.pictureUrl != "" {
            cell.avatarImageView.image = UIImage(named: person.pictureUrl)
        }
        cell.avatarPlaceholderLabel.text = person.initials
        
        return cell
    }
    
    func markSelectedAndUpdateCollection(cell: PeopleTableViewCell, indexPath: NSIndexPath, avatarCollectionView: UICollectionView) {
        cell.isSelectedForInvite = true
        
        let user = cell.user
        selectedUsers.append(user)
        cell.selectedImageView.hidden = false
        avatarCollectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: selectedUsers.count - 1, inSection: 0)])
    }
    
    func markDeselectedAndUpdateCollection(cell: PeopleTableViewCell, indexPath: NSIndexPath, avatarCollectionView: UICollectionView) {
        cell.isSelectedForInvite = false
        
        cell.selectedImageView.hidden = true
        if let index = getAvatarCollectionIndex(cell) {
            selectedUsers.removeAtIndex(index)
            avatarCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
        }
    }
    
    /**
    Method searches through selected users and returns if the user is present
    
    - parameter id: user id
    */
    private func isSelectedWithId(id:Int) -> Bool {
        return Bool(selectedUsers.filter({$0.id == id}).count)
    }
    
    /**
    Method searches through selected users and returns position of user if present
    
    - parameter id: user id
    */
    private func getAvatarCollectionIndex(cell: PeopleTableViewCell) -> Int? {
        for (index, user) in selectedUsers.enumerate() {
            if user.id == cell.user.id {
                return index
            }
        }
        
        return nil
    }
    
}