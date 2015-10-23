/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class ParkScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var leftNumber: UILabel!
    @IBOutlet weak var leftName: UILabel!
    @IBOutlet weak var leftScore: UILabel!
    
    @IBOutlet weak var rightNumber: UILabel!
    @IBOutlet weak var rightName: UILabel!
    @IBOutlet weak var rightScore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        leftNumber.layer.cornerRadius = leftNumber.bounds.height/2
        rightNumber.layer.cornerRadius = rightNumber.bounds.height/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
