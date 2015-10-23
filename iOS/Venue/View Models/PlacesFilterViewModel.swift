/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// This class implements the view model for the Filter screen
class PlacesFilterViewModel: NSObject {
    
    private(set) var poiTypes: [Type] = []
    private(set) var poiSelected: [Bool] = []
    var heightFilter = 24
    var minimumHeightValue = 24
    var waitFilter = 0
    var minimumWaitValue = 0
    private var heightViewModel: FilterSliderViewModel!
    private var waitViewModel: FilterSliderViewModel!

    
    override init() {
        super.init()
        
        // Initialize the slider view models
        heightViewModel = FilterSliderViewModel(filterTitle: NSLocalizedString("Minimum Height Requirement", comment: ""), unitLabel: NSLocalizedString("\"", comment: ""), minimumValue: minimumHeightValue, maximumValue: 64, stepAmount: 4, startingValue: heightFilter)
        waitViewModel = FilterSliderViewModel(filterTitle: NSLocalizedString("Ride Wait Time", comment: ""), unitLabel: NSLocalizedString(" min", comment: ""), minimumValue: minimumWaitValue, maximumValue: 60, stepAmount: 5, startingValue: waitFilter)
        
        // Get the POI types for the collection view
        poiTypes = ApplicationDataManager.sharedInstance.loadPoiTypesFromCoreData()
        for poi in poiTypes {
            poiSelected.append(poi.isSelected)
        }
    }
    
    /**
    Sets up a cell of a filter type for the Collection View.
    
    - parameter cell:      The cell to setup
    - parameter indexPath: The index path of the cell
    */
    func setupFilterCell(cell: FilterCollectionCell, indexPath: NSIndexPath) {
        let filter = poiTypes[indexPath.row]
        let isSelected = poiSelected[indexPath.row]
        let isClearFiltersCell = indexPath.row == (poiSelected.count - 1)
        
        // The "Clear Filters" cell is handled differently (navy blue, no selected state, etc)
        if isClearFiltersCell {
            cell.filterLabel.textColor = UIColor.venueNavyBlue()
        }
        
        cell.filterLabel.text = filter.name
        if isSelected {
            cell.filterImageView.image = UIImage(named: filter.selected_image_name)
            if !isClearFiltersCell {
                cell.filterLabel.textColor = UIColor.venueRed()
            }
        } else {
            cell.filterImageView.image = UIImage(named: filter.unselected_image_name)
            if !isClearFiltersCell {
                cell.filterLabel.textColor = UIColor.venueDarkGray()
            }
        }
    }
    
    /**
    Passes the height & wait view models to the slider views
    
    - parameter view: The Footer view that contains the height and wait times
    */
    func setupFilterFooterView(view: FilterCollectionFooterView) {
        
        if view.heightFilterView.viewModel == nil {
            view.heightFilterView.viewModel = heightViewModel
        }
        
        if view.waitFilterView.viewModel == nil {
            view.waitFilterView.viewModel = waitViewModel
        }
    }
    
    /**
    Sets up the highlighted state for a cell
    
    - parameter cell:      The cell to highlight
    - parameter indexPath: The index path of the cell
    */
    func highlightedFilterCell(cell: FilterCollectionCell, indexPath: NSIndexPath) {
        let isClearFiltersCell = indexPath.row == (poiSelected.count - 1)

        if !poiSelected[indexPath.row] {
            cell.filterImageView.image = UIImage(named: poiTypes[indexPath.row].selected_image_name)
            if !isClearFiltersCell {
                cell.filterLabel.textColor = UIColor.venueRed()
            }
        } else {
            cell.filterImageView.image = UIImage(named: poiTypes[indexPath.row].unselected_image_name)
            if !isClearFiltersCell {
                cell.filterLabel.textColor = UIColor.venueDarkGray()
            }
        }
    }
    
    /**
    Sets up the unhighlighted state for a cell
    
    - parameter cell:      The cell to highlight
    - parameter indexPath: The index path of the cell
    */
    func unhighlightedFilterCell(cell: FilterCollectionCell, indexPath: NSIndexPath) {
        let isClearFiltersCell = indexPath.row == (poiSelected.count - 1)
        
        if poiSelected[indexPath.row] {
            cell.filterImageView.image = UIImage(named: poiTypes[indexPath.row].selected_image_name)
            if !isClearFiltersCell {
                cell.filterLabel.textColor = UIColor.venueRed()
            }
        } else {
            cell.filterImageView.image = UIImage(named: poiTypes[indexPath.row].unselected_image_name)
            if !isClearFiltersCell {
                cell.filterLabel.textColor = UIColor.venueDarkGray()
            }
        }
    }
    
    /**
    Handles what happens when a filter cell is selected.
    
    - parameter cell:      The cell that was selected
    - parameter indexPath: The index path of the cell that was selected
    */
    func selectedFilterCell(cell: FilterCollectionCell, indexPath: NSIndexPath) {
        poiSelected[indexPath.row] = !poiSelected[indexPath.row]
        let isClearFiltersCell = indexPath.row == (poiSelected.count - 1)
        
        // only need to change the state of the cell if it is NOT the Clear Filters cell
        if !isClearFiltersCell {
            if poiSelected[indexPath.row] {
                cell.filterImageView.image = UIImage(named: poiTypes[indexPath.row].selected_image_name)
                cell.filterLabel.textColor = UIColor.venueRed()
            } else {
                cell.filterImageView.image = UIImage(named: poiTypes[indexPath.row].unselected_image_name)
                cell.filterLabel.textColor = UIColor.venueDarkGray()
            }
        }
    }
    
    /**
    Determine whether the Clear Filters cell has been selected, if so all filters are cleared.
    
    - returns: True if the filters need to be reset, false otherwise
    */
    func shouldResetFilters() -> Bool {
        if poiSelected.last! {
            resetFilters()
            return true
        }
        return false
    }
    
    /**
    Goes through and resets all the filters to their "off" state
    */
    func resetFilters() {
        for var index = 0; index < poiTypes.count; ++index {
            poiSelected[index] = false
        }
        heightViewModel.currentValue = heightViewModel.minimumValue
        waitViewModel.currentValue = waitViewModel.minimumValue
    }
    
    /**
    Saves the state of the filters to be applied to the map
    */
    func applyFilters() {
        var filtersCleared = true
        
        // If the filters have been cleared, set the selected state (applies to the filter page) to false,
        // and set the display state (applies to the map) to true
        for selected in poiSelected {
            if selected {
                filtersCleared = false
            }
        }
        
        for (index, value) in poiSelected.enumerate() {
            if filtersCleared {
                poiTypes[index].isSelected = false
                poiTypes[index].shouldDisplay = true
            } else {
                poiTypes[index].isSelected = value
                poiTypes[index].shouldDisplay = value
            }
        }
        
        
        heightFilter = heightViewModel.currentValue.integerValue
        waitFilter = waitViewModel.currentValue.integerValue
    }
    
    /**
    Resets the filters to the values when the Filter view was first shown.
    */
    func cancelFilters() {
        heightViewModel.currentValue = heightFilter
        waitViewModel.currentValue = waitFilter
        
        for (index, type) in poiTypes.enumerate() {
            poiSelected[index] = type.isSelected
        }
    }
}
