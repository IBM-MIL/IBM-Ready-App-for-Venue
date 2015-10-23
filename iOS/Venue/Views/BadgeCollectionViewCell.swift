/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// UICollectionViewCell used in the BadgeCollectionView
class BadgeCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var badgeTitle: UILabel!
    
    let cellToImageRatio: CGFloat = 0.75
    
    override func prepareForReuse() {
        badgeImageView.subviews.last?.removeFromSuperview()
    }
}
