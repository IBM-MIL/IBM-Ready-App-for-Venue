/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// cell user in people list view controller to display a person
class PeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var imagePlaceholder: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var dividerView: UIView!
    
    var user: User!
    
    // verbose due to name conflict for 'isSelected'
    var isSelectedForInvite = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imagePlaceholder.layer.cornerRadius = imagePlaceholder.frame.height/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
