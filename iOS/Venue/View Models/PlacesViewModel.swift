/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import ReactiveCocoa
import CoreLocation

/// This is the view model for the Places (Map) View 
class PlacesViewModel: NSObject {
    
    private let locationManager = CLLocationManager()
    private let filterViewModel = PlacesFilterViewModel()
    
    private(set) var mapImageName: String!
    private(set) var currentUser: User?
    private var pois : [POI]?
    private var people : [User]?
    private var visiblePois: [POI] = []
    private var visiblePeople: [User] = []
    private var zoomToUser = true
    private var resetMap = true
    private dynamic var headingDegrees: CGFloat = 0
    
    var headingSignal: RACSignal!
    let myListFilterID = 12
    
    override init() {
        super.init()
        
        // Setup the reactive setting for the user's heading
        headingSignal = RACObserve(self, keyPath: "headingDegrees")
        
        mapImageName = "map"
    }
    
    // MARK: Initial Map Setup Functions
    
    /**
    Determines whether the map should be reset (zoom out and center map). This will only
    happen the first time the user goes to the map page.
    
    :returns: Bool indicating whether to zoom out on the map
    */
    func shouldResetMap() -> Bool {
        if resetMap {
            resetMap = false
            return true
        }
        return false
    }
    
    /**
    Determines whether the map should zoom in on the current user. This will only
    happen the first time the user goes to the map page.
    
    :returns: Bool indicating whether to zoom in on the current user
    */
    func shouldZoomToUser() -> Bool {
        if zoomToUser {
            zoomToUser = false
            return true
        }
        return false
    }
    
    /**
    Gets the current user's data
    
    :returns: The current user's data object
    */
    func getCurrentUser() -> User? {
        // Setup location manager to track the user's heading
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        
        return UserDataManager.sharedInstance.currentUser
    }
    
    /**
    Gets the list of My People for the current user.
    
    :parameter: callback The method to pass the My People dictionary to
    */
    func getMyPeople(callback: ([Int: User])->()) {
        
        // Ask data manager for array of all users
        let peopleManager = UserDataManager.sharedInstance
        peopleManager.getUsers(UserDataManager.sharedInstance.currentUser.group.id) { [weak self] (allUsersData: [User]) in
            
            guard let strongSelf = self else {
                return
            }
            
            // Get currrent user from list of users and remove from array. Build my people dictionary
            strongSelf.people = allUsersData
            strongSelf.visiblePeople = allUsersData
            var myPeopleDict: [Int: User] = [:]
            for (index, person) in allUsersData.enumerate() {
                if person.email != CurrentUserDemoSettings.getCurrentUserEmail() {
                    myPeopleDict[person.id] = person
                } else {
                    strongSelf.people!.removeAtIndex(index)
                    strongSelf.visiblePeople.removeAtIndex(index)
                }
            }
            callback(myPeopleDict)
        }
    }
    
    /**
    Gets the list of Points of Interest This does an MFP call, but for demo purposes 
    will ignore the returned data and just use the static data from Core Data
    
    :parameter: callback The method to pass the POI Dictionary to
    */
    func getPOIs(callback: ([Int: POI])->()) {
        
        // Ask data manager for array of POIs
        let poiManager = PoiDataManager.sharedInstance
        poiManager.getPOIData() { [weak self] (poiData: [POI]) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.pois = poiData
            strongSelf.visiblePois = poiData
            var pointsOfInterestDict: [Int: POI] = [:]
            for poi in poiData {
                pointsOfInterestDict[poi.id] = poi
            }
            callback(pointsOfInterestDict)
        }
    }
    
    // MARK: Filtering functions
    
    /**
    Function to get the view model for the Filter screen.
    
    - returns: The filter view model
    */
    func viewModelForFilters() -> PlacesFilterViewModel {
        return filterViewModel
    }
    
    /**
    Tells the filter view model to reset and apply the filters
    */
    func clearFilters() {
        self.filterViewModel.resetFilters()
        self.filterViewModel.applyFilters()
    }
    
    /**
    Applies the filter from the filter view model to the POI and People annotations. Also updates the list
    of visible POIs and People for use in the detailed collection view.
    
    - parameter pois:   The dictionary of POI map annotations
    - parameter people: The dictionary of People map annotations
    */
    func applyFilters(pois: [Int: POIAnnotation], people: [Int: MyPeopleAnnotation]) {
        
        // Check if My List was filtered, if so, get the current user's list of favorites
        var currentUsersFavorites: [FavoritedPOI]?
        for type in filterViewModel.poiTypes {
            if (type.id == myListFilterID) && (type.shouldDisplay) {
                currentUsersFavorites = UserDataManager.sharedInstance.currentUser.favorites
            }
        }
        
        visiblePois = []
        for (_, poi) in pois {
            
            // If height/wait filters hide this annotation, move on to next annotation
            if filterViewModel.heightFilter > filterViewModel.minimumHeightValue {
                if poi.filterHeight(filterViewModel.heightFilter) {
                    continue
                }
            } else if filterViewModel.waitFilter > filterViewModel.minimumWaitValue {
                if poi.filterWaitTime(filterViewModel.waitFilter) {
                    continue
                }
            }

            
            // Check if this poi is part of My Plan
            if let currentUsersFavorites = currentUsersFavorites {
                let filteredArray = currentUsersFavorites.filter { $0.favoritedPOI.id == poi.poiObject.id }
                if  !filteredArray.isEmpty {
                    poi.hidden = false
                    visiblePois.append(poi.poiObject)
                    continue
                }
            }
            
            // Otherwise filter based on type
            poi.applyFilter(filterViewModel.poiTypes)
            if !poi.hidden {
                visiblePois.append(poi.poiObject)
            }
        }
        
        visiblePeople = []
        for (_, person) in people {
            person.appyFilter(filterViewModel.poiTypes)
            if !person.hidden {
                visiblePeople.append(person.userObject)
            }
        }
    }
    

    // MARK: Detail Collection View Functions

    /**
    Returns the number of annotations that should be visible
    
    - returns: The count of visible annotations
    */
    func visibleAnnotationsCount() -> Int {
        return visiblePois.count + visiblePeople.count
        
    }
    
    /**
    Given a generic annotation, get the index in the data source for the detail collection view.
    
    - parameter annotation: A VenueMapAnnotation to find the index for
    
    - returns: Returns the index in the data source for the given annotation
    */
    func indexOfAnnotation(annotation: VenueMapAnnotation) -> Int {
        if let annotation = annotation as? POIAnnotation {
            if let index = visiblePois.indexOf(annotation.poiObject) {
                return index
            } else {
                print("Warning: Couldn't find index of POI Annotation")
            }
        } else if let annotation = annotation as? MyPeopleAnnotation {
            if var index = visiblePeople.indexOf(annotation.userObject) {
                index = index + visiblePois.count
                return index
            } else {
                print("Warning: Couldn't find index of My People Annotation")
            }
        }

        return 0
    }
    
    /**
    Returns an object for the POI or User object at a given index
    
    - parameter index: The index for the annotation
    
    - returns: An NSObject that will be either a POI or a Person
    */
    func annotationObjectAtIndex(var index: Int) ->NSObject? {
        if index < visiblePois.count {
            return visiblePois[index]
        } else {
            index = index - visiblePois.count
            return visiblePeople[index]
        }
    }
    
    /**
    Sets up the UI for the Detail Collection View cell. This is pass by reference, so no need to return the cell
    
    - parameter cell:      The cell to setup
    - parameter indexPath: The index path for this cell.
    */
    func setupDetailCell(cell: PlacesDetailCollectionViewCell, indexPath: NSIndexPath) {
        if indexPath.row < visiblePois.count {
            let poi = visiblePois[indexPath.row]
            cell.detailImageView.image = UIImage(named: poi.thumbnailUrl)
            cell.detailNameLabel.text = poi.name
            cell.setWaitTime(poi.wait_time)
            
            let firstType = poi.types.first!
            cell.detailTypeImageView.image = UIImage(named: firstType.home_icon_image_name)
        } else {
            let index = indexPath.row - visiblePois.count
            let person = visiblePeople[index]
            cell.detailNameLabel.text = person.name
            cell.detailImageView.image = UIImage(named: person.pictureUrl)
            cell.detailTypeImageView.image = UIImage(named: "Icons_Home_People")
            cell.avatarPlaceholderLabel.text = person.initials
            cell.setWaitTime(-1)
        }
    }
}

// MARK: Location Manager Delegate

extension PlacesViewModel: CLLocationManagerDelegate {
    /**
    Protocol method that is called when the user's heading is changed.
    */
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.headingDegrees = CGFloat(newHeading.magneticHeading)
    }
}
