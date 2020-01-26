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
        
        let f1 = CGRect(x: self.view.frame.width*(1/10), y: 30, width: self.view.frame.width*(8/10), height: 30)
        let completed_view = UIView(frame: f1)
        completed_view.backgroundColor = UIColor.gray
        
        let f2 = CGRect(x: 0, y: 0, width: f1.width, height: f1.height)
        let text_view = UILabel(frame: f2)
        text_view.textAlignment = .center
        text_view.text = "Back"
        
        completed_view.addSubview(text_view)
        self.view.addSubview(completed_view)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.finished))
        completed_view.isUserInteractionEnabled = true
        completed_view.addGestureRecognizer(tap)

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
