/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

/// Custom cell for displaying a person's image or initials in the place invite screen
class AvatarImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var avatarPlaceholderLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarPlaceholderLabel.layer.cornerRadius = avatarPlaceholderLabel.frame.size.height / 2
    }
}