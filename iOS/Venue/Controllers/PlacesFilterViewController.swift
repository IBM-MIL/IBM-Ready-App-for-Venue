/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

protocol FilterDelegate: class {
    func applyFilters()
}

/// This class present the Filter view for the Map page
class PlacesFilterViewController: VenueUIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    
    weak var viewModel: PlacesFilterViewModel?
    weak var delegate: FilterDelegate?
    
    let itemsPerRow: CGFloat = 4.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.clearColor()
        
        setupBindings()
    }

    /**
    Sets up the reactive bindings for the Close and Apply buttons
    */
    func setupBindings() {
        closeButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [unowned self] _ in
            self.viewModel!.cancelFilters()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        applyButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [unowned self] _ in
            self.viewModel!.applyFilters()
            self.delegate?.applyFilters()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

// MARK: - UICollectionView Delegate and Datasource

extension PlacesFilterViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let _ = viewModel else {
            return 0
        }
        return viewModel!.poiSelected.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCell", forIndexPath: indexPath) as! FilterCollectionCell
        viewModel!.setupFilterCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    /**
    Adds the footer view to the collection view. The filter view contains the sliders for Wait Time and Height Requirement
    */
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "FooterView", forIndexPath: indexPath) as! FilterCollectionFooterView
        viewModel!.setupFilterFooterView(footerView)
        return footerView
    }
    
    /**
    Tells the view model that a cell was selected, then checks if the Collection View needs to be reloaded. This would happen
    if the Clear Filters option had been selected.
    */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FilterCollectionCell
        viewModel!.selectedFilterCell(cell, indexPath: indexPath)
        if viewModel!.shouldResetFilters() {
            collectionView.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FilterCollectionCell
        viewModel!.highlightedFilterCell(cell, indexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FilterCollectionCell
        viewModel!.unhighlightedFilterCell(cell, indexPath: indexPath)
    }
}

// MARK: - UICollectionView Flow Layout
extension PlacesFilterViewController: UICollectionViewDelegateFlowLayout {
    
    /**
    Lays out the cells in the Collection View so that they are evenly spaced with 4 cells per row on any screen size.
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = flowLayout.itemSize.width
        let totalWidth = collectionView.frame.size.width
        let availableWidth = totalWidth - (itemWidth * itemsPerRow)
        let leftRightInset = floor((availableWidth / 5))

        return UIEdgeInsets(top: flowLayout.sectionInset.top, left: leftRightInset, bottom: flowLayout.sectionInset.bottom, right: leftRightInset)
    }
    
    /**
    Lays out the cells in the Collection View so that they are evenly spaced with 4 cells per row on any screen size.
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = flowLayout.itemSize.width
        let totalWidth = collectionView.frame.size.width
        let availableWidth = totalWidth - (itemWidth * itemsPerRow)
        return floor((availableWidth / 5))
    }
}
