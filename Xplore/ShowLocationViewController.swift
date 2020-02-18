//
//  ShowLocationViewController.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 25/01/2020.
//  Copyright © 2020 Kevin Jiang. All rights reserved.
//

import UIKit
import Mapbox

class ShowLocationViewController: UIViewController, MGLMapViewDelegate {

    var location : CLLocationCoordinate2D?

    var mapView = MGLMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var address = ""
    let annotation = MGLPointAnnotation()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView = MGLMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        //        mapView.styleURL = URL(string: "mapbox://styles/kev2018/cjytf3psp05u71cqm0l0bacgt")
        self.mapView.styleURL = URL(string: "mapbox://styles/kev2018/cjytijoug092v1cqz0ogvzb0w")
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        
        let f1 = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 63)
        let completed_view = UIView(frame: f1)
        completed_view.backgroundColor = UIColor.white
        
        let f2 = CGRect(x: 8, y: 17, width: 70, height: 29)
        let back_button = UIButton(frame: f2)
        back_button.setTitle("back", for: .normal)
        back_button.setTitleColor(UIColor(red:0, green:1, blue:0.761, alpha:1), for: .normal)
        back_button.titleLabel!.font = UIFont(name: "Futura-Bold", size: 17)
        
        completed_view.addSubview(back_button)
        self.view.addSubview(completed_view)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.finished))
//        completed_view.isUserInteractionEnabled = true
//        completed_view.addGestureRecognizer(tap)
        
        back_button.addTarget(self, action: #selector(self.finished), for: .allEvents)

        let loc = location!
                     
                //Add map and button to scroll view
        self.annotation.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        self.annotation.title = "Event location"
        self.mapView.addAnnotation(self.annotation)

        self.mapView.setCenter(CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude), zoomLevel: 13, animated: false)
        }
        
    @objc func finished() {
        self.dismiss(animated: true, completion: nil)
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
