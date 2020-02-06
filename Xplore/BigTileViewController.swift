//
//  BigTileViewController.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 17/01/2020.
//  Copyright © 2020 Kevin Jiang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class BigTileViewController: UIViewController {
    
    var event : Event?
    
    @IBOutlet var capacity: UILabel!
    @IBOutlet var event_title: UILabel!
    
    @IBOutlet var address: UILabel!
    
    @IBOutlet var from_date: UILabel!
    @IBOutlet var from_time: UILabel!
    
    @IBOutlet var to_date: UILabel!
    @IBOutlet var to_time: UILabel!
    
    @IBOutlet var event_description: UILabel!
    
    @IBOutlet var view_academic: RoundUIView!
    @IBOutlet var view_arts: RoundUIView!
    @IBOutlet var view_athletic: RoundUIView!
    @IBOutlet var view_casual: RoundUIView!
    @IBOutlet var view_professional: RoundUIView!
    @IBOutlet var view_social: RoundUIView!
    
    
    @IBOutlet var tags_academic: UILabel!
    @IBOutlet var tags_art: UILabel!
    @IBOutlet var tags_athletic: UILabel!
    @IBOutlet var tags_casual: UILabel!
    @IBOutlet var tags_professional: UILabel!
    @IBOutlet var tags_social: UILabel!
    
    @IBOutlet var addressView: RoundUIView!

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let db = Firestore.firestore()

    
    @IBAction func addBookmark(_ sender: Any) {
        currentUser?.eventsUserBookmarked.append(self.db.collection("events").document(event!.documentID!))
        
        if let e = event {
            let point = CustomPointAnnotation(coordinate: e.location, title: e.title, subtitle: "\(e.capacity) people", description: e.description, annotationType: AnnotationType.Event, event_id: e.documentID)
                       point.reuseIdentifier = "customAnnotation\(e.title)"
            point.image = InteractiveMap.dot(size: 30, num: e.capacity)
            
            bookmarks.append(Bookmark(event: event, annotation: point))
            bookmarksTable.reloadData()
            
            currentUser?.updateUser()
            
            self.dismiss(animated: true, completion: nil)
        }
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMap))
        self.addressView.addGestureRecognizer(tap)
        self.addressView.isUserInteractionEnabled = true
        
        event_title.text = event!.title
        address.text = event!.address
        
        let from = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute], from: event!.startDate)
        let to = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute], from: event!.endDate)
        
        from_date.text = "\(from.month!)/\(from.day!)/\(from.year!)"
        from_time.text = "\(from.hour!):\(from.minute!)"
        
        to_date.text = "\(to.month!)/\(to.day!)/\(to.year!)"
        to_time.text = "\(to.hour!):\(to.minute!)"

        event_description.text = event!.description
        
        print(event!.tags) //TODO
        
        let selected : UIColor = UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1)
        
        for tag in event!.tags {
            switch tag {
            case "Academic":
                view_academic.backgroundColor = selected
                tags_academic.textColor = UIColor.white
            case "Arts":
                view_arts.backgroundColor = selected
                tags_art.textColor = UIColor.white
            case "Athletic":
                view_athletic.backgroundColor = selected
                tags_athletic.textColor = UIColor.white
            case "Casual":
                view_casual.backgroundColor = selected
                tags_casual.textColor = UIColor.white
            case "Professional":
                view_professional.backgroundColor = selected
                tags_professional.textColor = UIColor.white
            case "Social":
                view_social.backgroundColor = selected
                tags_social.textColor = UIColor.white
            default:
                print ("oops. tbh this isn't the best code. should use enums")
            }
            
        }
        
        
    }
    
    @objc func showMap() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.performSegue(withIdentifier: "showLocation", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("PREPARING")
        if segue.identifier == "showLocation" {
            let dest = segue.destination as! ShowLocationViewController
            dest.location = event!.location
        }
        
        
       
    }
    


}
