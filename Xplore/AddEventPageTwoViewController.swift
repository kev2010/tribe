//
//  AddEventPageTwoViewController.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 26/11/2019.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class AddEventPageTwoViewController: UIViewController {

    @IBOutlet var academicTag: RoundUIView!
    @IBOutlet var artsTag: RoundUIView!
    @IBOutlet var professionalTag: RoundUIView!
    @IBOutlet var athleticTag: RoundUIView!
    @IBOutlet var socialTag: RoundUIView!
    @IBOutlet var casualTag: RoundUIView!
    
    
    @IBOutlet weak var academicLabel: UILabel!
    @IBOutlet weak var artsLabel: UILabel!
    @IBOutlet weak var athleticLabel: UILabel!
    @IBOutlet weak var casualLabel: UILabel!
    @IBOutlet weak var professionalLabel: UILabel!
    @IBOutlet weak var socialLabel: UILabel!
    
    
//    @IBOutlet var selectAddress: RoundUIView!
    
    
    @IBOutlet weak var background: RoundUIView!
    @IBOutlet weak var topUI: RoundUIView!
//    @IBOutlet weak var botUI: RoundUIView!
//    @IBOutlet weak var addressline: UIView!
    
    
//    @IBOutlet var saveLabel: RoundUIView!
    
    @IBOutlet var capacityField: UITextField!
    
    var prev_data: [String:Any] = [String:Any]()
    
    var tags : [String] = []
    
    var address_send = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 0.6)
//        let color2 = UIColor(red: 0/255, green: 182/255, blue: 255/255, alpha: 0.6)
//        background.addGradientLayer(topColor: color1, bottomColor: color2)
//        addressline.addGradientLayer(topColor: color1, bottomColor: color2)
        
//        topUI.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
//        botUI.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)


        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.academicTap))
        academicTag.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.artsTap))
        artsTag.addGestureRecognizer(tap2)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(self.athleticTap))
        athleticTag.addGestureRecognizer(tap4)
        
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(self.casualTap))
        casualTag.addGestureRecognizer(tap5)
        
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(self.professionalTap))
        professionalTag.addGestureRecognizer(tap6)
        
        let tap7 = UITapGestureRecognizer(target: self, action: #selector(self.socialTap))
        socialTag.addGestureRecognizer(tap7)
        
//         let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.saveTap))
//         saveLabel.addGestureRecognizer(tap3)
        

        

        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backTap(_ sender: UIButton) {
        self.dismiss(animated: true) {
            (self.presentingViewController as! AddEventViewController).goNext()
        }
    }
    
    
    @IBAction func saveTap(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.955)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
        
                // Create Address String

        var newLocation = CLLocationCoordinate2D()
        // Geocode Address String

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.address_send) { (placemarks, error) in
            if let error = error {
                print("Unable to Forward Geocode Address (\(error))")

            } else {
                var location: CLLocation?

                if let placemarks = placemarks, placemarks.count > 0 {
                    location = placemarks.first?.location
                }

                if let location = location {
                    let coordinate = location.coordinate
                    newLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)

                } else {
                    print("No matching locations found")
                }
            }
        }

        let newEvent = Event(creator_username: currentUser!.username, title: prev_data["title"] as! String, description: prev_data["description"] as! String, startDate: prev_data["start"] as! Date, endDate: prev_data["end"] as! Date, location: newLocation, address: "tbi", capacity: -1, visibility: "tbi", tags: self.tags, attendees: [currentUser!.username])
        
                    
        
        newEvent.saveEvent()
        
        //TODO: change tags label so it's an actual array. and location. actual dates too. and capacity.

        //  Exit SaveEvent
        self.dismiss(animated: true, completion: {})
        (self.presentingViewController as! AddEventViewController).close()
    }
    
    
    @objc func academicTap(_ sender: UITapGestureRecognizer) {
        

        // Note the first click doens't do anything for some reason? the clicks afterwards work perfectly
        if academicTag.backgroundColor != UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1) {
            academicTag.backgroundColor = UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1)
            academicLabel.textColor = .white
            self.tags.append("Academic")
        }
            
        else {
            academicTag.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1)
            academicLabel.textColor = .lightGray
            if let index = self.tags.firstIndex(of: "Academic") {
                self.tags.remove(at: index)
            }
        }

    }
    
    @objc func artsTap(_ sender: UITapGestureRecognizer) {
        

        // Note the first click doens't do anything for some reason? the clicks afterwards work perfectly
        if artsTag.backgroundColor != UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1) {
            artsTag.backgroundColor = UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1)
            artsLabel.textColor = .white
            self.tags.append("Arts")
        }
            
        else {
            artsTag.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1)
            artsLabel.textColor = .lightGray
            if let index = self.tags.firstIndex(of: "Arts") {
                self.tags.remove(at: index)
            }

        }

    }
    
    @objc func athleticTap(_ sender: UITapGestureRecognizer) {
        
        if athleticTag.backgroundColor != UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1) {
            athleticTag.backgroundColor = UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1)
            athleticLabel.textColor = .white
            self.tags.append("Athletic")
        }
            
        else {
            athleticTag.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1)
            athleticLabel.textColor = .lightGray
            if let index = self.tags.firstIndex(of: "Athletic") {
                self.tags.remove(at: index)
            }
        }

    }
    
    @objc func casualTap(_ sender: UITapGestureRecognizer) {
        
        if casualTag.backgroundColor != UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1) {
            casualTag.backgroundColor = UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1)
            casualLabel.textColor = .white
            self.tags.append("Casual")
        }
            
        else {
            casualTag.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1)
            casualLabel.textColor = .lightGray
            if let index = self.tags.firstIndex(of: "Casual") {
                self.tags.remove(at: index)
            }
        }

    }
    
    @objc func professionalTap(_ sender: UITapGestureRecognizer) {
        
        if professionalTag.backgroundColor != UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1) {
            professionalTag.backgroundColor = UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1)
            professionalLabel.textColor = .white
            self.tags.append("Professional")
        }
            
        else {
            professionalTag.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1)
            professionalLabel.textColor = .lightGray
            if let index = self.tags.firstIndex(of: "Professional") {
                self.tags.remove(at: index)
            }
        }

    }
    
    @objc func socialTap(_ sender: UITapGestureRecognizer) {
        
        if socialTag.backgroundColor != UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1) {
            socialTag.backgroundColor = UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1)
            socialLabel.textColor = .white
            self.tags.append("Social")
        }
            
        else {
            socialTag.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1)
            socialLabel.textColor = .lightGray
            if let index = self.tags.firstIndex(of: "Social") {
                self.tags.remove(at: index)
            }
        }

    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "confirmLocation" {
            let vc = segue.destination as! PickAddressViewController
            vc.address = self.address_send
        }
    
        
        
    }

}
