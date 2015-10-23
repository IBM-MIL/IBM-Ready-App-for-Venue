/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/// This view controller handles the Places (Map) view.
class PlacesViewController: VenueUIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContentView: UIView!
    @IBOutlet weak var detailsCollectionView: UICollectionView!
    @IBOutlet weak var detailsCollectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterButton: UIButton!
    private var mapImageView: UIImageView!
    private var imageSize: CGSize!
    private var defaultZoomLevel: CGFloat = 0.6
    
    private var viewModel = PlacesViewModel()
    
    private var poiMapAnnotations: [Int: POIAnnotation] = [:]
    private var myPeopleAnnotations: [Int: MyPeopleAnnotation] = [:]
    private var currentLocationAnnotation: MyLocationAnnotation?
    private var currentlySelectedAnnotation: VenueMapAnnotation?
    private var didSetContentSize = false
    
     //set either of these objects before seguing to this view to "select" an annotation on view did appear
    var initialPOI: POI?
    var initialUser: User?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.None
        
        // Add the map image to the scroll view
        let image = UIImage(named: viewModel.mapImageName)
        imageSize = image!.size
        mapImageView = UIImageView(image: image)
        self.scrollViewContentView.addSubview(mapImageView)
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Hide the details view at load.
        detailsCollectionView.backgroundColor = UIColor.clearColor()
        detailsCollectionViewBottomConstraint.constant = -(detailsCollectionView.frame.size.height)
        self.updateViewConstraints()
        
        // Get all the necessary objects
        getCurrentUserLocation()
        getPoiObjects()
        getUserObjects()
        
        // Setup Reactive bindings
        self.setupBindings()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var didResetContentSize = false
        
        // The first time this view is shown, we need to do some things with regards to the scroll view content size and 
        // focusing on the current user
        if viewModel.shouldResetMap() {
            scrollView.contentSize = imageSize
            didSetContentSize = true
            determineMinimumZoomScale()
        } else {
            // Sometimes (hard to reproduce) the content size of the scrollView gets reset, so we have to check for that case.
            if (scrollView.contentSize.width != imageSize.width * scrollView.zoomScale) || (scrollView.contentSize.height != imageSize.height * scrollView.zoomScale){
                scrollView.zoomScale = 1.0
                scrollView.contentSize = imageSize
                
                didResetContentSize = true
            }
        }
        
        // Check to see if we need to select a POI
        if checkInitialPOI() {
            return
        }
        
        // Check to see if we need to select a person
        if checkInitialUser() {
            return
        }
        
        if didResetContentSize {
            // Check if something is selected and zoom to it
            if let currentlySelectedAnnotation = currentlySelectedAnnotation {
                zoomToAnnotation(currentlySelectedAnnotation, zoomScale: defaultZoomLevel)
                return
            }
        }
        
        if didResetContentSize || viewModel.shouldZoomToUser() {
            // Otherwise check if the currentLocation annotation has been created and zoom to it
            if let currentLocationAnnotation = currentLocationAnnotation {
                zoomToAnnotation(currentLocationAnnotation, zoomScale: defaultZoomLevel)
                return
            }
        }
    }
    
    /**
    Checks to see if the initialPOI object has been set and then zooms to that POI. The initialPOI object is set by another object when the user
    is going to the map from another location in the app
    
    - returns: Returns true if there was an initial POI object to zoom to, otherwise false
    */
    func checkInitialPOI() -> Bool {
        if initialPOI != nil {
            viewModel.clearFilters()
            self.applyFilters()
            if let annotation = poiMapAnnotations[initialPOI!.id] {
                if !annotation.currentlySelected && !annotation.hidden {
                    annotation.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                } else {
                    zoomToAnnotation(annotation, zoomScale: defaultZoomLevel)
                }
                initialPOI = nil
                return true
            }
        }
        
        return false
    }
    
    /**
    Checks to see if the initialUser object has been set and then zooms to that user. The initialUser object is set by another object when the user
    is going to the map from another location in the app
    
    - returns: Returns true if there was an initial user object to zoom to, otherwise false
    */
    func checkInitialUser() -> Bool {
        if initialUser != nil {
            viewModel.clearFilters()
            self.applyFilters()
            if let annotation = myPeopleAnnotations[initialUser!.id] {
                if !annotation.currentlySelected && !annotation.hidden {
                    annotation.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                } else {
                    zoomToAnnotation(annotation, zoomScale: defaultZoomLevel)
                }
                initialUser = nil
                return true
            }
        }
        return false
    }
    
    // MARK: Map setup and scroll view helper functions
    
    /**
    Sets up any necessary Reactive Bindings to the view model
    */
    func setupBindings() {
        
        // Subscribes to the Heading signal, which will update when the heading of the phone changes
        viewModel.headingSignal.subscribeNextAs() { (heading: CGFloat) in
            if let annotation = self.currentLocationAnnotation {
                let rotationAmount = (heading * CGFloat(M_PI)) / 180.0
                dispatch_async(dispatch_get_main_queue()) {
                    annotation.transform = CGAffineTransformMakeRotation(rotationAmount)
                }
            }
        }
        
        // Present the Filter View Controller when the Filter button is pressed
        filterButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { [unowned self] _ in
            let filterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FilterViewController") as! PlacesFilterViewController
            filterViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
            filterViewController.transitioningDelegate = self
            filterViewController.delegate = self
            filterViewController.viewModel = self.viewModel.viewModelForFilters()
            self.presentViewController(filterViewController, animated: true, completion: nil)
        }
    }
    
    /**
    Computes the minimum zoom scale so that the user can't zoom out to far on the map.
    */
    func determineMinimumZoomScale() {
        let contentWidth = scrollView.contentSize.width
        let contentHeight = scrollView.contentSize.height
        let scrollViewWidth = scrollView.frame.size.width
        let scrollViewHeight = scrollView.frame.size.height
        
        let width = scrollViewWidth / contentWidth
        let height = scrollViewHeight / contentHeight
        
        let scale = max(width, height)
        
        if scale != scrollView.minimumZoomScale {
            scrollView.minimumZoomScale = scale
        }
    }
    
    /**
    Sets the view of the map to be centered and all the way zoomed out
    */
    func resetMapView() {
        let scrollViewSize = self.scrollView.bounds.size
        let scrollwidth = scrollViewSize.width / scrollView.minimumZoomScale
        let scrollheight = scrollViewSize.height / scrollView.minimumZoomScale
        let x = (scrollwidth / 2.0)
        let y = (scrollheight / 2.0)
        
        let rectToZoomInto = CGRect(x: x, y: y, width: scrollwidth, height: scrollheight)
        self.scrollView.zoomToRect(rectToZoomInto, animated:false)
    }
    
    /**
    Zooms into an annotation with the given zoom scale
    
    :param: annotation The annotation to zoom and center on
    :param: zoomScale  The zoom scale to apply
    */
    func zoomToAnnotation(annotation: VenueMapAnnotation, zoomScale: CGFloat) {
        
        let scrollViewSize = self.scrollView.bounds.size
        let width = scrollViewSize.width / zoomScale
        let height = scrollViewSize.height / zoomScale
        let x = annotation.getReferencePoint().x  - (width / 2.0)
        let y = annotation.getReferencePoint().y  - (height / 2.0)
        
        let rectToZoomInto = CGRect(x: x, y: y, width: width, height: height)
        self.scrollView.zoomToRect(rectToZoomInto, animated:true)
    }
    
    // MARK: Data queries
    
    /**
    Asks the view model for the current user object. If the user has already been added to the map, create it and add to the map.
    Otherwise update the location.
    */
    func getCurrentUserLocation() {
        if let currentUser = viewModel.getCurrentUser() {
            currentUser.updateUserLocation() { (location: CGPoint) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let userAnnotation = self.currentLocationAnnotation {
                        userAnnotation.updateReferencePoint(location, mapZoomScale: self.scrollView.zoomScale)
                        userAnnotation.userObject = currentUser
                        self.updateAnnotationOnMap(userAnnotation)
                    } else {
                        self.currentLocationAnnotation = MyLocationAnnotation(user: currentUser, location: location)
                        self.addBindingToAnnotation(self.currentLocationAnnotation!)
                        self.scrollView.addSubview(self.currentLocationAnnotation!)
                        self.updateAnnotationOnMap(self.currentLocationAnnotation!)
                    }
                    if self.didSetContentSize {
                        if self.initialUser == nil && self.initialPOI == nil {
                            self.zoomToAnnotation(self.currentLocationAnnotation!, zoomScale: self.defaultZoomLevel)
                        }
                    }
                }
            }
        }
    }
    
    /**
    Asks the view model for a dictionary of Points of Interest. If a POI has not been added to the map, create it and add.
    If the POI already exists on the map, update the location.
    */
    func getPoiObjects() {
        viewModel.getPOIs() { (poiDict: [Int: POI]) in
            dispatch_async(dispatch_get_main_queue()) {
                for poi in poiDict {
                    let poiKey = poi.0
                    let poiObject = poi.1
                    
                    if let annotation = self.poiMapAnnotations[poiKey] {
                        annotation.updateReferencePoint(CGPoint(x: poiObject.coordinateX, y: poiObject.coordinateY), mapZoomScale: self.scrollView.zoomScale)
                        annotation.poiObject = poiObject
                        self.updateAnnotationOnMap(annotation)
                    } else {
                        let annotation = POIAnnotation(poi: poiObject, location: CGPoint(x: poiObject.coordinateX, y: poiObject.coordinateY), zoomScale: self.scrollView.zoomScale)
                        self.poiMapAnnotations[poiKey] = annotation
                        self.addBindingToAnnotation(annotation)
                        self.scrollView.addSubview(annotation)
                        self.updateAnnotationOnMap(annotation)
                    }
                }
                self.detailsCollectionView.reloadData()
            
                if self.didSetContentSize {
                    // Check if we need to select one of these POIs
                    self.checkInitialPOI()
                }
            }
        }
    }
    
    /**
    Asks the view model for a dictionary of MyPeople. If a person annotation has not been added to the map, create it and add.
    If the person annotation already exists on the map, update the location.
    */
    func getUserObjects() {
        viewModel.getMyPeople() { (myPeopleDict: [Int: User]) in
            dispatch_async(dispatch_get_main_queue()) {
                for user in myPeopleDict {
                    let userKey = user.0
                    let userObject = user.1
                    userObject.updateUserLocation() { (location: CGPoint) in
                        
                        if let annotation = self.myPeopleAnnotations[userKey] {
                            annotation.updateReferencePoint(location, mapZoomScale: self.scrollView.zoomScale)
                            annotation.userObject = userObject
                            self.updateAnnotationOnMap(annotation)
                        } else {
                            let annotation = MyPeopleAnnotation(user: user.1, location: CGPoint(x: location.x, y: location.y), zoomScale: self.scrollView.zoomScale)
                            self.myPeopleAnnotations[userKey] = annotation
                            self.addBindingToAnnotation(annotation)
                            self.scrollView.addSubview(annotation)
                            self.updateAnnotationOnMap(annotation)
                            
                        }
                    }
                    self.detailsCollectionView.reloadData()
                    
                }
                
                if self.didSetContentSize {
                    // Check if we need to select this person
                    self.checkInitialUser()
                }
            }
        }
    }
    
    // MARK: View updates for annotations and details view
    
    /**
    Moves the annotation on the map according to the zoom scale and the content offset of the scroll view
    
    :param: annotation The annotation to update
    */
    func updateAnnotationOnMap(annotation: VenueMapAnnotation) {
        let scale = self.scrollView.zoomScale
        annotation.updateLocation(scale)
    }

    /**
    Adds a reactive listener to all of the annotations to handle what happens when an annotation is tapped!
    */
    func addBindingToAnnotation(annotation: VenueMapAnnotation) {
        
        annotation.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { annotation in
            
            if let genericAnnotation = annotation as? VenueMapAnnotation {
                genericAnnotation.annotationSelected(self.scrollView.zoomScale)
                if genericAnnotation.currentlySelected {
                    self.currentlySelectedAnnotation?.annotationSelected(self.scrollView.zoomScale)
                    self.zoomToAnnotation(genericAnnotation, zoomScale: self.defaultZoomLevel)
                    self.currentlySelectedAnnotation = genericAnnotation
                    self.scrollView.bringSubviewToFront(genericAnnotation)
                    
                    let index = self.viewModel.indexOfAnnotation(genericAnnotation)
                    self.detailsCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
                    self.showDetailView()
                } else {
                    self.currentlySelectedAnnotation = nil
                    self.hideDetailView()
                }
            }
        }
    }
    
    /**
    Animates the details view to be shown
    */
    func showDetailView() {
        if self.detailsCollectionViewBottomConstraint.constant < 0 {
            self.detailsCollectionViewBottomConstraint.constant = 0
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { Void in
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    /**
    Animates the details view to be hidden
    */
    func hideDetailView() {
        if self.detailsCollectionViewBottomConstraint.constant >= 0 {
            self.detailsCollectionViewBottomConstraint.constant = -(detailsCollectionView.frame.size.height)
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { Void in
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    // MARK: Navigation
    
    /**
    Navigates to the place details screen. Passes the view model for the Place Detail page to the next view controller
    */
    func goToPlaceDetails() {
        guard let poiAnnotation = currentlySelectedAnnotation as? POIAnnotation else {
            return
        }
        let placeDetailViewController = Utils.vcWithNameFromStoryboardWithName("placeDetail", storyboardName: "Places") as! PlaceDetailViewController
        placeDetailViewController.viewModel = PlacesDetailViewModel(poi: poiAnnotation.poiObject)
        self.navigationController?.pushViewController(placeDetailViewController, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PersonDetailsStoryboardSegue" {
            guard let personDetailViewController = segue.destinationViewController as? PersonDetailsViewController, let personAnnotation = currentlySelectedAnnotation as? MyPeopleAnnotation else {
                return
            }
            
            personDetailViewController.viewModel = PersonDetailsViewModel(person: personAnnotation.userObject)
        }
    }
}

// MARK: Scroll view delegate

extension PlacesViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return mapImageView
    }

    /**
    When the scroll view is zooming, need to update the annotations on the map
    
    :param: scrollView The scroll view that zoomed
    */
    func scrollViewDidZoom(scrollView: UIScrollView) {
        for annotation in poiMapAnnotations {
            updateAnnotationOnMap(annotation.1)
        }
        for annotation in myPeopleAnnotations {
            updateAnnotationOnMap(annotation.1)
        }
        if let annotation = currentLocationAnnotation {
            updateAnnotationOnMap(annotation)
        }
    }
    
    /**
    If the scroll view in the collection view has finished moving, need to select
    the corresponding annotation in the map to the selected annotaion in the collection view.
    
    - parameter scrollView: The scroll view that finished scrolling
    */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if let _ = scrollView as? UICollectionView {
            self.scrollingHasEnded()
        }
    }
    
    /**
    If the scroll view in the collection view has finished moving, need to select
    the corresponding annotation in the map to the selected annotaion in the collection view.
    
    - parameter scrollView: The scroll view that finished scrolling
    */
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if let _ = scrollView as? UICollectionView {
            self.scrollingHasEnded()
        }
    }
    
    /**
    Helper method to find current index patho n collectionview
    
    :returns: the current NSIndexPath
    */
    func firstVisibleIndex() -> Int {
        let currentIndex = self.detailsCollectionView.contentOffset.x / self.detailsCollectionView.frame.size.width
        return Int(currentIndex)
    }
    
    /**
    Get the visible annotation detail, and select the corresponding annotation on the map
    */
    func scrollingHasEnded() {
        
        let index = self.firstVisibleIndex()
        
        /// Used to update annotations if necessary
        let object = viewModel.annotationObjectAtIndex(index)
        if let poiObject = object as? POI {
            let annotation = self.poiMapAnnotations[poiObject.id]!
            if !annotation.currentlySelected {
                annotation.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            }
        } else if let userObject = object as? User {
            let annotation = self.myPeopleAnnotations[userObject.id]!
            if !annotation.currentlySelected {
                annotation.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            }
        }
    }
}

// MARK: Filter delegate

extension PlacesViewController: FilterDelegate {
    /**
    Called by the Filter View Controller. Makes sure no annotations are selected, and applies the filter 
    to the view model.
    */
    func applyFilters() {
        self.currentlySelectedAnnotation?.sendActionsForControlEvents(.TouchUpInside)
        self.currentlySelectedAnnotation = nil
        self.viewModel.applyFilters(poiMapAnnotations, people: myPeopleAnnotations)
        self.detailsCollectionView.reloadData()
    }
}

// MARK: UICollectionView Delegate, Data Source, Flow Layout

extension PlacesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.visibleAnnotationsCount()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PlacesDetailCell", forIndexPath: indexPath) as! PlacesDetailCollectionViewCell
        viewModel.setupDetailCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    /**
    If a POI or User detail card is selected, determine which type it was and perform the necessary navigation tasks.
    
    */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let _ = currentlySelectedAnnotation as? POIAnnotation {
            self.goToPlaceDetails()
        } else if let _ = currentlySelectedAnnotation as? MyPeopleAnnotation {
            self.performSegueWithIdentifier("PersonDetailsStoryboardSegue", sender: self)
        }
    }
}

// MARK: Custom transistion delegate

extension PlacesViewController: UIViewControllerTransitioningDelegate{
    
    /**
    Delegate method for a custom transition needed to show the view controller from the top
    */
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = ReverseCoverVertical()
        transition.presenting = true
        return transition
    }
    
    /**
    Delegate method for a custom transition needed to dismiss the view controller back to the top
    */
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = ReverseCoverVertical()
        transition.presenting = false
        return transition
    }
}
