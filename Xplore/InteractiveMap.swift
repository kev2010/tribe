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
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet weak var backBut: UIButton!
    
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
    
//    @objc func goBack(sender: UIButton) {
//        print("button clicked")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        backButton.addTarget(self, action: #selector(self.goBack(sender:)), for: .touchUpInside)
        
        // Configure location manager to user's location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
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
