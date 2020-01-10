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
    
    @IBOutlet var selectAddress: RoundUIView!
    
    
    @IBOutlet weak var background: RoundUIView!
    @IBOutlet weak var topUI: RoundUIView!
    @IBOutlet weak var botUI: RoundUIView!
    @IBOutlet weak var addressline: UIView!
    
    
    @IBOutlet var saveLabel: RoundUIView!
    
    @IBOutlet var capacityField: UITextField!
    
    var prev_data: [String:Any] = [String:Any]()
    
    var tags : [String] = []
    
    var address_send = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 0.6)
        let color2 = UIColor(red: 0/255, green: 182/255, blue: 255/255, alpha: 0.6)
        background.addGradientLayer(topColor: color1, bottomColor: color2)
//        addressline.addGradientLayer(topColor: color1, bottomColor: color2)
        
        topUI.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        botUI.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)


        
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
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.saveTap))
        saveLabel.addGestureRecognizer(tap3)
        

        
        let pickAddress = UITapGestureRecognizer(target: self, action: #selector(self.addressTap))
        selectAddress.addGestureRecognizer(pickAddress)
        
        // Do any additional setup after loading the view.
    }
    
    
    @objc func saveTap(_ sender: UITapGestureRecognizer) {
        

               
                    
        
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
                }
                

    @objc func addressTap(_ sender: UITapGestureRecognizer) {
        
        self.performSegue(withIdentifier: "confirmLocation", sender: self)
    }
    
    
    @objc func academicTap(_ sender: UITapGestureRecognizer) {
        
        if academicTag.backgroundColor == UIColor.white {
            academicTag.backgroundColor = UIColor(red: 0, green: 182/255, blue: 1.0, alpha: 0.6)
            self.tags.append("Academic")
        }
            
        else {
            self.academicTag.backgroundColor = UIColor.white
            if let index = self.tags.firstIndex(of: "Academic") {
                self.tags.remove(at: index)
            }
        }

    }
    
    @objc func artsTap(_ sender: UITapGestureRecognizer) {
        
        if artsTag.backgroundColor == UIColor.white {
            artsTag.backgroundColor = UIColor(red: 0, green: 182/255, blue: 1.0, alpha: 0.6)
            self.tags.append("Arts")
        }
            
        else {
            self.artsTag.backgroundColor = UIColor.white
            if let index = self.tags.firstIndex(of: "Arts") {
                self.tags.remove(at: index)
            }
        }

    }
    
    @objc func athleticTap(_ sender: UITapGestureRecognizer) {
        
        if athleticTag.backgroundColor == UIColor.white {
            athleticTag.backgroundColor = UIColor(red: 0, green: 182/255, blue: 1.0, alpha: 0.6)
            self.tags.append("Athletic")
        }
            
        else {
            athleticTag.backgroundColor = UIColor.white
            if let index = self.tags.firstIndex(of: "Athletic") {
                self.tags.remove(at: index)
            }
        }

    }
    
    @objc func casualTap(_ sender: UITapGestureRecognizer) {
        
        if casualTag.backgroundColor == UIColor.white {
            casualTag.backgroundColor = UIColor(red: 0, green: 182/255, blue: 1.0, alpha: 0.6)
            self.tags.append("Casual")
        }
            
        else {
            casualTag.backgroundColor = UIColor.white
            if let index = self.tags.firstIndex(of: "Casual") {
                self.tags.remove(at: index)
            }
        }

    }
    
    @objc func professionalTap(_ sender: UITapGestureRecognizer) {
        
        if professionalTag.backgroundColor == UIColor.white {
            professionalTag.backgroundColor = UIColor(red: 0, green: 182/255, blue: 1.0, alpha: 0.6)
            self.tags.append("Professional")
        }
            
        else {
            professionalTag.backgroundColor = UIColor.white
            if let index = self.tags.firstIndex(of: "Professional") {
                self.tags.remove(at: index)
            }
        }

    }
    
    @objc func socialTap(_ sender: UITapGestureRecognizer) {
        
        if socialTag.backgroundColor == UIColor.white {
            socialTag.backgroundColor = UIColor(red: 0, green: 182/255, blue: 1.0, alpha: 0.6)
            self.tags.append("Social")
        }
            
        else {
            socialTag.backgroundColor = UIColor.white
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
