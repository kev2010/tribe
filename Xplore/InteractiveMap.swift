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
        print(botleft)
        print(topright)
        print("*(")
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
        backButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(self.goBack), for: UIControl.Event.touchDown)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        
        //Load map view
        mapView = MGLMapView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
//        mapView.styleURL = MGLStyle.darkStyleURL
        let customStyleURL = Bundle.main.url(forResource: "third_party_vector_style", withExtension: "json")!
        mapView.styleURL = customStyleURL
        mapView.tintColor = .lightGray
        mapView.delegate = self
        
        
        //Add map and button to scroll view
        self.view.addSubview(mapView)
//        self.pageView.addSubview(mapView)
        self.mapView.addSubview(backButton)
        
        addRandomEvents()
        
        
        // Configure location manager to user's location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    
    func addRandomEvents() {
        let bottom = CLLocationCoordinate2D(latitude: 37.775834, longitude: -122.41641700000001)
        let top = CLLocationCoordinate2D(latitude: 37.795834, longitude: -122.396417)
        
        let event1_loc = CLLocationCoordinate2D(latitude: 37.779834, longitude: -122.39941700000001)
        let event2_loc = CLLocationCoordinate2D(latitude: 37.791834, longitude: -122.4101700000001)

        let event_1 = Event(name: "Phi Sig Party", coordinates: event1_loc, numPeople: 40)
        let event_2 = Event(name: "Kevin's room", coordinates: event2_loc, numPeople: 5)
        
        let allEvents = [event_1, event_2]
        
        // Fill an array with point annotations and add it to the map.
        var pointAnnotations = [CustomPointAnnotation]()
        for event in allEvents {
            let point = CustomPointAnnotation(coordinate: event.coordinates, title: event.name, subtitle: "\(event.numPeople) people")
            point.reuseIdentifier = "customAnnotation\(event.name)"
            point.image = dot(size: 30, num: event.numPeople)

            pointAnnotations.append(point)
        }
        
        mapView.addAnnotations(pointAnnotations)
    }
    

    

    // MARK: - MGLMapViewDelegate methods
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let point = annotation as? CustomPointAnnotation,
            let image = point.image,
            let reuseIdentifier = point.reuseIdentifier {
            
            if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier) {
                // The annotatation image has already been cached, just reuse it.
                return annotationImage
            } else {
                // Create a new annotation image.
                return MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
            }
        }
        
        // Fallback to the default marker image.
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    
    // MARK: - Navigation
    
    @objc func goBack() {
        self.performSegue(withIdentifier: "toMain", sender: self)
    }
    
    
    // MARK: - Helper
    
    func getHeatMapColor(numPeople: Int) -> String{
        
        switch numPeople {
        case 0:
            return heatmap_smallToBig[1]
            
        case 1..<5:
            return heatmap_smallToBig[2]
            
        case 5..<15:
            return heatmap_smallToBig[3]
            
        case 15..<30:
            return heatmap_smallToBig[4]
            
        case 30..<50:
            return heatmap_smallToBig[5]
            
        case 50..<100:
            return heatmap_smallToBig[6]
            
        default:
            return heatmap_smallToBig[7]
        }
        
    }
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func dot(size: Int, num:Int) -> UIImage {
        let floatSize = CGFloat(size)
        let rect = CGRect(x: 0, y: 0, width: floatSize, height: floatSize)
        let strokeWidth: CGFloat = 1
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        let ovalPath = UIBezierPath(ovalIn: rect.insetBy(dx: strokeWidth, dy: strokeWidth))
        hexStringToUIColor(hex: getHeatMapColor(numPeople: num)).setFill()
        ovalPath.fill()
        
        UIColor.white.setStroke()
        ovalPath.lineWidth = strokeWidth
        ovalPath.stroke()
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }

}
