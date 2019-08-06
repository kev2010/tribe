//
//  InteractiveMap.swift
//  Xplore
//
//  Created by Kevin Jiang on 8/2/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Mapbox
import Firebase

class InteractiveMap: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate{
    //  MapBox custom map - to change map style, go to storyboard -> MapView -> Attributes -> Style URL
//    @IBOutlet var mapView: MGLMapView!
    
    
    
    @IBOutlet var pageView: UIScrollView!
    
    let manager = CLLocationManager()
    
    // Bottom tile variables - global
    var topTileShowing = false
    var topTile = UIView()
    var bottom_titleLabel = UILabel()
    var bottom_subtitleLabel = UILabel()
    var bottom_descriptionLabel = UILabel()
    
    //Big tile variablees - global
    var bigTile = UIView()
    var big_titleLabel = UILabel()
    var big_subtitleLabel = UILabel()
    var big_entranceLabel  = UILabel()
    var big_descriptionLabel = UILabel()
    var big_exitButton = UIButton()
    
    
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
//        let customStyleURL = Bundle.main.url(forResource: "third_party_vector_style", withExtension: "json")!
        mapView.styleURL = URL(string: "mapbox://styles/kev2018/cjytf3psp05u71cqm0l0bacgt")
//        mapView.tintColor = .lightGray
        mapView.delegate = self
        
        
        //Add map and button to scroll view
        self.view.addSubview(mapView)
        self.mapView.addSubview(backButton)
        
        let allEvents = addRandomEvents()
        
        addEventsToMap(events: allEvents)
        
        // Configure location manager to user's location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        loadBottomTile()
        loadBigTile()
        
    }
    
    
    func addRandomEvents() ->  [Event]{

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        var start = formatter.date(from: "2019/08/06 21:00")
        var end = formatter.date(from: "2019/08/06 23:00")

        let event_1  = Event(creator_username: "kevin", avatar: nil, title: "Phi Sig Party", description: "Come to Phi Sig for cages, Mo's dancing and a wild party that won't get shut down at 11pm", startDate: start!, endDate: end!, location: CLLocationCoordinate2D(latitude: 37.779834, longitude: -122.39941), capacity: 50, visibility: "PUBLIC", tags: ["party", "cages"], attendees: ["kevin"])
        
        start = formatter.date(from: "2019/08/08 20:00")
        end = formatter.date(from: "2019/08/08 23:00")
        
        let event_2 = Event(creator_username: "kevin", avatar: nil, title: "Kevin's room", description: "Poker night, texas holdem. Come and get destroyed by the king of poker himself.", startDate: start!, endDate: end!, location: CLLocationCoordinate2D(latitude: 37.791834, longitude: -122.41017), capacity: 15, visibility: "FRIENDS", tags: ["poker", "games"], attendees: ["kevin"])
        
        let allEvents = [event_1, event_2]
        
        for event in allEvents {
            event.saveEvent()
        }
        
        return allEvents

    }
    
    func addEventsToMap(events:[Event]) {
        
        // Fill an array with point annotations and add it to the map.
        var pointAnnotations = [CustomPointAnnotation]()
        for event in events {
            let point = CustomPointAnnotation(coordinate: event.location, title: event.title, subtitle: "\(event.capacity) people", description: event.description)
            point.reuseIdentifier = "customAnnotation\(event.title)"
            point.image = dot(size: 30, num: event.capacity)
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

    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if let point = annotation as? CustomPointAnnotation {
            
            if topTileShowing {
                bottom_titleLabel.text = point.title!
                bottom_subtitleLabel.text  = point.subtitle!
                bottom_descriptionLabel.text = point.desc!
            }
            else {

                bottom_titleLabel.text = point.title!
                bottom_subtitleLabel.text  = point.subtitle!
                bottom_descriptionLabel.text = point.desc!
                
                showTopTile(show: true)
                
                topTileShowing = true
            }
            
            
    }
    }
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        if topTileShowing {
            showTopTile(show: false)
            topTileShowing = false
        }  else {
            print("here")
            showBigTile(show: false)
        }
    }
    
    // MARK: - Navigation
    
    @objc func goBack() {
        self.performSegue(withIdentifier: "toMain", sender: self)
    }
    


    
    // MARK: - Helper
    
    func showTopTile(show:Bool, hide:Bool = false) {
        
//        if hide {
////            self.bottomTile.alpha = 0.0
//
//            UIView.animate(withDuration: 0.2) {
//                self.topTile.frame.origin = CGPoint(x: 20, y: -130)
//            }
//            topTileShowing = false
//            return
//        }
        if show {
            self.topTile.alpha = 1.0
            UIView.animate(withDuration: 0.2) {
                self.topTile.frame.origin = CGPoint(x: 20, y: 50)
            }
            topTileShowing = true
        } else {
            UIView.animate(withDuration: 0.2) {
                self.topTile.frame.origin = CGPoint(x: 20, y: -130)
            }
            topTileShowing = false
        }

    }
    
    
    func showBigTile(show:Bool) {
        
        if show {
            showTopTile(show: false, hide: true)
            
            UIView.animate(withDuration: 0.2) {
                self.bigTile.frame.origin = CGPoint(x: 20, y: self.view.frame.height/6)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.bigTile.frame.origin = CGPoint(x: 20, y: -self.view.frame.height)
            }
        }
        
    }
    
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
    
    func loadBottomTile() {
        let f = CGRect(x: 20, y: -130, width: self.view.frame.width-40, height: 130)
        topTile = UIView(frame: f)
        topTile.backgroundColor = UIColor.white
        topTile.layer.cornerRadius = 10

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bottomTileTap(sender:)))
        
        // 2. add the gesture recognizer to a view
        topTile.addGestureRecognizer(tapGesture)

        
        let f2 = CGRect(x: 10, y: 10, width: f.width-10, height: 20)
        bottom_titleLabel = UILabel(frame: f2)
        bottom_titleLabel.text = ""
        bottom_titleLabel.textColor =  UIColor.black
        bottom_titleLabel.textAlignment = .center
        
        let f3 = CGRect(x: 10, y: 40, width: f.width-10, height: 20)
        bottom_subtitleLabel = UILabel(frame:f3)
        bottom_subtitleLabel.text  = ""
        bottom_subtitleLabel.textColor =  UIColor.black
        
        let f4 = CGRect(x: 10, y: 80, width: f.width-10, height: 40)
        bottom_descriptionLabel = UILabel(frame:f4)
        bottom_descriptionLabel.text = ""
        bottom_descriptionLabel.textColor =  UIColor.black
        bottom_descriptionLabel.numberOfLines = 5
        bottom_descriptionLabel.font = UIFont.italicSystemFont(ofSize: 16.0)
    
        topTile.addSubview(bottom_titleLabel)
        topTile.addSubview(bottom_subtitleLabel)
        topTile.addSubview(bottom_descriptionLabel)
        
        self.mapView.addSubview(topTile)
        
        
    }
    

    func loadBigTile() {
        let f = CGRect(x: 20, y: -(2*self.view.frame.height/3), width: self.view.frame.width-40, height: 2*self.view.frame.height/3)
        bigTile = UIView(frame: f)
        bigTile.backgroundColor = UIColor.white
        bigTile.layer.cornerRadius = 10

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bigTileTap(sender:)))
        
        // 2. add the gesture recognizer to a view
        bigTile.addGestureRecognizer(tapGesture)
        
        
        let f2 = CGRect(x: 10, y: 10, width: f.width-10, height: 30)
        big_titleLabel = UILabel(frame: f2)
        big_titleLabel.text = ""
        big_titleLabel.textColor =  UIColor.black
        big_titleLabel.textAlignment = .center
        
        let f2_2 = CGRect(x: bigTile.frame.width-30, y: 15, width: 15, height: 15)
        big_exitButton = UIButton(frame: f2_2)
        big_exitButton.setTitle("X", for: UIControl.State.normal)
        big_exitButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        big_exitButton.addTarget(self, action: #selector(dismissBigTile), for: .touchUpInside)


        let f3 = CGRect(x: 10, y: 50, width: f.width-10, height: 30)
        big_subtitleLabel = UILabel(frame:f3)
        big_subtitleLabel.text  = ""
        big_subtitleLabel.textColor =  UIColor.black
        
        let f4 = CGRect(x: 10, y: 90, width: f.width-10, height: 50)
        big_descriptionLabel = UILabel(frame:f4)
        big_descriptionLabel.text = ""
        big_descriptionLabel.textColor =  UIColor.black
        big_descriptionLabel.numberOfLines = 5
        big_descriptionLabel.font = UIFont.italicSystemFont(ofSize: 16.0)
        
        let f4_2 = CGRect(x: 10, y: 150, width: f.width-10, height: 50)
        big_entranceLabel = UILabel(frame:f4_2)
        big_entranceLabel.text = ""
        big_entranceLabel.textColor =  UIColor.black
        big_entranceLabel.numberOfLines = 3

        let f5 = CGRect(x: 30, y: bigTile.frame.height - 70, width: 50, height: 50)
        let left_box = UIView(frame: f5)
        left_box.backgroundColor = hexStringToUIColor(hex: "#F66745")
        left_box.layer.cornerRadius = 10

        let f6 = CGRect(x: (bigTile.frame.width/2)-25, y: bigTile.frame.height - 70, width: 50, height: 50)
        let middle_box = UIView(frame: f6)
        middle_box.backgroundColor = hexStringToUIColor(hex: "#F66745")
        middle_box.layer.cornerRadius = 10
        
        let f7 = CGRect(x: bigTile.frame.width-80, y: bigTile.frame.height - 70, width: 50, height: 50)
        let right_box = UIView(frame: f7)
        right_box.backgroundColor = hexStringToUIColor(hex: "#F66745")
        right_box.layer.cornerRadius = 10

        let w = bigTile.frame.width - 50
        let f8 = CGRect(x: 25, y: 250, width: w, height: 2*w/3)
        let image_map = UIImageView(frame: f8)
        image_map.image = UIImage(named: "map_example.jpg")
        image_map.layer.cornerRadius = 10
        
        bigTile.addSubview(left_box)
        bigTile.addSubview(middle_box)
        bigTile.addSubview(right_box)
        bigTile.addSubview(image_map)
        
        bigTile.addSubview(big_titleLabel)
        bigTile.addSubview(big_exitButton)
        bigTile.addSubview(big_subtitleLabel)
        bigTile.addSubview(big_descriptionLabel)
        bigTile.addSubview(big_entranceLabel)
        
        self.mapView.addSubview(bigTile)
        
    }
    
    @objc func dismissBigTile(sender: UIButton!) {
        showBigTile(show: false)
    }

    @objc func bottomTileTap(sender: UITapGestureRecognizer) {
        
        big_titleLabel.text = bottom_titleLabel.text
        big_subtitleLabel.text = bottom_subtitleLabel.text
        big_descriptionLabel.text = bottom_descriptionLabel.text
        big_entranceLabel.text = "Entry details: up the stairs and to the right, flat 4. "
        
       showBigTile(show: true)
    }
    
    @objc func bigTileTap(sender: UITapGestureRecognizer) {
        
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
