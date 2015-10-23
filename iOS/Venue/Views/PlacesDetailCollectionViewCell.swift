/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// This class present the detailed cell on the Places screen for POIs and People
class PlacesDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarPlaceholderLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet private weak var detailWaitLabel: VenueWaitLabel!
    @IBOutlet weak var detailTypeImageView: UIImageView!
    @IBOutlet private weak var detailNameTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var detailWaitBottomConstraint: NSLayoutConstraint!
    
    private var saveTopConstraint: CGFloat = 0
    private var saveBottomConstraint: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()

        saveTopConstraint = detailNameTopConstraint.constant
        saveBottomConstraint = detailWaitBottomConstraint.constant
        detailImageView.layer.cornerRadius = detailImageView.frame.size.width / 2
        avatarPlaceholderLabel.layer.cornerRadius = avatarPlaceholderLabel.frame.size.height / 2
    }
    
    /**
    Sets the wait time label of the detailed cell. If the wait time is less than 0, we 
    want to hide the wait time label.
    
    - parameter waitTime: The wait time in minutes for the POI
    */
    func setWaitTime(waitTime: Int) {
        if waitTime >= 0 {
            self.showWaitLabel()
            detailWaitLabel.text = "\(waitTime)" + NSLocalizedString(" min", comment: "")
        } else {
            self.hideWaitLabel()
            detailWaitLabel.text = NSLocalizedString("No wait", comment: "")
        }
        detailWaitLabel.updateTextColor(waitTime)
    }
    
    /**
    Moves the wait time label off the screen and centers the Name label
    */
    private func hideWaitLabel() {
        detailNameTopConstraint.constant = (self.frame.size.height / 2) - (detailNameLabel.frame.size.height / 2)
        detailWaitBottomConstraint.constant = -detailWaitLabel.frame.size.height
        
        UIView.animateWithDuration(0.3, animations: { Void in
            self.updateConstraints()
        })
    }
    
    /**
    Moves the wait time label on the screen
    */
    private func showWaitLabel() {
        detailNameTopConstraint.constant = saveTopConstraint
        detailWaitBottomConstraint.constant = saveBottomConstraint
        
        UIView.animateWithDuration(0.3, animations: { Void in
            self.updateConstraints()
        })
    }
}
