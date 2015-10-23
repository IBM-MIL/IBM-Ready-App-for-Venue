/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// Cell used on home screen to display POIs in slightly different ways
class POITableViewCell: UITableViewCell {
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: VenueWaitLabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var waitTimeImageView: UIImageView!
    @IBOutlet weak var subtitleLeadingConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var waitTimeCircleYConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleYConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTitleYConstraint: NSLayoutConstraint!
    
    let iconWidthDiff: CGFloat = 11
    var originalSubtitleConstraintConstant: CGFloat!
    
    private var originalWaitYConstraint: CGFloat = 0
    private var originalSubtitleYConstraint: CGFloat = 0
    private var originalMainTitleYConstraint: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        originalSubtitleConstraintConstant = subtitleLeadingConstraint.constant

        originalWaitYConstraint = waitTimeCircleYConstraint.constant
        originalSubtitleYConstraint = subtitleYConstraint.constant
        originalMainTitleYConstraint = mainTitleYConstraint.constant
    }
    
    /**
    Method to move text over for items without a wait time
    
    - parameter hidden: value determining if `waitTimeImageView` should be hidden
    */
    func toggleWaitTimeHidden(hidden: Bool) {
        
        waitTimeImageView.hidden = hidden
        if hidden {
            subtitleLeadingConstraint.constant = originalSubtitleConstraintConstant - iconWidthDiff
        } else {
            subtitleLeadingConstraint.constant = originalSubtitleConstraintConstant
        }
    }
    
    /**
    Moves the wait time label off the screen and centers the Main title label
    */
    func hideWaitLabel() {
        
        waitTimeCircleYConstraint.constant = -waitTimeImageView.height
        subtitleYConstraint.constant = -subtitleLabel.height
        mainTitleYConstraint.constant = 0
        
        UIView.animateWithDuration(0.3) { self.updateConstraints() }
    }
    
    /**
    Resets cell labels to their original position
    */
    func showWaitLabel() {

        waitTimeCircleYConstraint.constant = originalWaitYConstraint
        subtitleYConstraint.constant = originalSubtitleYConstraint
        mainTitleYConstraint.constant = originalMainTitleYConstraint
        
        UIView.animateWithDuration(0.3) { self.updateConstraints() }
    }

}
