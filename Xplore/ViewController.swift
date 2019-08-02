//
//  ViewController.swift
//  Xplore
//
//  Created by Kevin Jiang on 7/31/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    //  MapBox custom map - to change map style, go to storyboard -> MapView -> Attributes -> Style URL
    @IBOutlet var mapView: MGLMapView!
    
    let manager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //  Determine user's current location and save boundaries
        let location = locations[0]
        let botleft = CLLocationCoordinate2D(latitude: location.coordinate.latitude - 0.01, longitude: location.coordinate.longitude - 0.01)
        let topright = CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.01, longitude: location.coordinate.longitude + 0.01)
        let region:MGLCoordinateBounds = MGLCoordinateBounds(sw: botleft, ne: topright)
        
        //  Display the user's region onto screen
        mapView.setVisibleCoordinateBounds(region, animated: false)
        self.mapView.showsUserLocation = true
        print(location.speed, location.altitude)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure location manager to user's location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()

    }

}

