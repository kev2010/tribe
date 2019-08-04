//
//  InteractiveMap.swift
//  Xplore
//
//  Created by Kevin Jiang on 8/2/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Mapbox

class InteractiveMap: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate{
    //  MapBox custom map - to change map style, go to storyboard -> MapView -> Attributes -> Style URL
//    @IBOutlet var mapView: MGLMapView!
    
    @IBOutlet var pageView: UIScrollView!
    
    let manager = CLLocationManager()
    
    var mapView = MGLMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //  Determine user's current location and save boundaries
        let location = locations[0]
        let botleft = CLLocationCoordinate2D(latitude: location.coordinate.latitude - 0.01, longitude: location.coordinate.longitude - 0.01)
        let topright = CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.01, longitude: location.coordinate.longitude + 0.01)
        let region:MGLCoordinateBounds = MGLCoordinateBounds(sw: botleft, ne: topright)

        //  Display the user's region onto screen
        mapView.setVisibleCoordinateBounds(region, animated: false)
        mapView.showsUserLocation = true
        print(location.speed, location.altitude)
    }
    

    @IBAction func toHome(_ sender: UIButton) {
        print("go back!!!")
        self.performSegue(withIdentifier: "toMain", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create back  button
        let f = CGRect(x: 10, y: 40, width: 50, height: 50)
        let backButton = UIButton(frame: f)
        backButton.setTitle("<", for: UIControl.State.normal)
        backButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(self.goBack), for: UIControl.Event.touchDown)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        
        //Load map view
        mapView = MGLMapView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))

        
        //Add map and button to scroll view
        self.view.addSubview(mapView)
//        self.pageView.addSubview(mapView)
        self.mapView.addSubview(backButton)
        
        
        // Configure location manager to user's location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    @objc func goBack() {
        self.performSegue(withIdentifier: "toMain", sender: self)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
