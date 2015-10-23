/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// Cell used in sorting menu on notifications screen
class NotificationMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var menuOptionLabel: UILabel!
    @IBOutlet weak var menuIconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.contentView.backgroundColor = UIColor.venueSelectionBlue()
        } else {
            self.contentView.backgroundColor = UIColor.clearColor()
        }
    }
}
