/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class MapViewController: UIViewController {
    
    let applicationDataManager = ApplicationDataManager.sharedInstance

    @IBOutlet weak var mapImageView: UIImageView!
    var mapDrawn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.bluetoothManager.mapController = self
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearMap() {
        for subview in mapImageView.subviews {
            subview.removeFromSuperview()
        }
        mapDrawn = false
    }
    
    func drawMap() {
        
        guard let currentUser = applicationDataManager.currentUser else {
            return
        }
        
        guard !mapDrawn else {
            return
        }
        
//        placeCurrentUser()
        
        for user in applicationDataManager.users {
            placeUserOnMap(user)
        }
        
        for poi in currentUser.plans {
//        for poi in ApplicationDataManager.sharedInstance.pois {
            placePOIOnMap(poi)
        }
        
        mapDrawn = true
    }
    
    func placeCurrentUser() {
        
        guard let currentUser = applicationDataManager.currentUser else {
            return
        }
        
        let markerWidth: CGFloat = 30
        let markerHeight: CGFloat = 30
        
        let scaleX = (view.frame.size.width+50)/1968
        let scaleY = (view.frame.size.height)/1932
        
        let x = (CGFloat(currentUser.currentLocationX) - markerWidth/2) * scaleX
        let y = (CGFloat(currentUser.currentLocationY) - markerHeight) * scaleY
        
        if let markerIcon = UIImage(named: "your_location") {
            let markerView = UIButton(frame: CGRectMake(x, y, markerWidth, markerHeight))
            markerView.setBackgroundImage(markerIcon, forState: UIControlState.Normal)
            markerView.userInteractionEnabled = false
            mapImageView.addSubview(markerView)
        }
        
    }
    
    func placeUserOnMap(user: User) {
        
        guard user != applicationDataManager.currentUser else {
            return
        }
        
        let markerDiameter: CGFloat = 22
        
        let scaleX = (view.frame.size.width+50)/1968
        let scaleY = (view.frame.size.height)/1932
        
        let x = (CGFloat(user.currentLocationX) - markerDiameter/2) * scaleX
        let y = (CGFloat(user.currentLocationY) - markerDiameter/2) * scaleY
        
        let markerView = UIView(frame: CGRectMake(x, y, markerDiameter, markerDiameter))
        markerView.layer.cornerRadius = markerDiameter/2
        markerView.backgroundColor = UIColor.blueColor()
        
        let initialsLabel = UILabel(frame: CGRectMake(0,0,markerDiameter,markerDiameter))
        initialsLabel.textColor = UIColor.whiteColor()
        initialsLabel.textAlignment = NSTextAlignment.Center
        initialsLabel.font = UIFont.boldSystemFontOfSize(12.0)
        initialsLabel.text = user.initials
        
        markerView.addSubview(initialsLabel)
        markerView.alpha = 0.0
        mapImageView.addSubview(markerView)
        
        UIView.animateWithDuration(0.5, animations: {
            markerView.alpha = 1.0
        })
        
        
    }
    
    func placePOIOnMap(poi: POI) {
        
        let markerWidth: CGFloat = 15
        let markerHeight: CGFloat = 20
        
        let scaleX = (view.frame.size.width+45)/1968
        let scaleY = (view.frame.size.height+30)/1932
        
        let x = (CGFloat(poi.coordinateX) - markerWidth/2) * scaleX
        let y = (CGFloat(poi.coordinateY) - markerHeight*2) * scaleY
        
        if let markerIcon = UIImage(named: poi.types[0].pin_image_name) {
            let markerView = UIImageView(image: markerIcon)
            markerView.frame.origin.x = x
            markerView.frame.origin.y = y
            markerView.alpha = 0.0
            mapImageView.addSubview(markerView)
            
            UIView.animateWithDuration(0.5, animations: {
                markerView.alpha = 1.0
            })
        }
        
        
    }

}
