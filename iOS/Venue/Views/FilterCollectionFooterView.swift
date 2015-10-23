/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/
import UIKit

/// This class presents a UICollectionView footer view with two FilterSliderViews 
class FilterCollectionFooterView: UICollectionReusableView {
        
    @IBOutlet weak var heightFilterView: FilterSliderView!
    @IBOutlet weak var waitFilterView: FilterSliderView!
}
