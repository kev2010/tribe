//
//  Event.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 04/08/2019.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import Foundation
import Mapbox
import Firebase

class Event {
    
    var creator_username : DocumentReference
    var avatar :  String?
    var title  : String
    var description : String
    var startDate : Date
    var endDate : Date
    var location : CLLocationCoordinate2D
    var capacity : Int
    var visibility : String
    var tags : [String]
    var attendees : [String]
    
    var documentID : String?
    
    
    init(creator_username:String, avatar:String?, title:String, description:String, startDate:Date, endDate: Date, location: CLLocationCoordinate2D, capacity:Int, visibility:String, tags:[String], attendees:[String]) {
        let db = Firestore.firestore()

        self.creator_username = db.document("users/\(creator_username)")
        self.avatar = avatar
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.capacity = capacity
        self.visibility = visibility
        self.tags = tags
        self.attendees = attendees
        self.documentID = nil
    }
    
    init(fromDatabaseFile file: QueryDocumentSnapshot) {
        let data = file.data()
        
        self.documentID = file.documentID
        
        self.creator_username = data["creator_username"] as! DocumentReference
        
        let information = data["information"] as! [String:Any]

        self.avatar = information["avatar"] as? String
        
        self.title = information["title"] as! String
        self.description = information["description"] as! String
        
        self.startDate = (information["startDate"] as! Timestamp).dateValue()
        self.endDate = (information["endDate"] as! Timestamp).dateValue()
        let loc = information["location"] as! GeoPoint
        self.location = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        self.capacity = information["capacity"] as! Int
        self.visibility = information["visibility"] as! String
        self.tags = information["tags"] as! [String]
        
        self.attendees = data["attendees"] as! [String]
    }
    
    
    func generate_information_map() -> [String:Any] {
        let information : [String:Any] = [
            "avatar": self.avatar,
            "title": self.title,
            "description": self.description,
            "startDate" : Timestamp(date: self.startDate),
            "endDate"  : Timestamp(date: self.endDate),
            "location" : GeoPoint(latitude: self.location.latitude, longitude: self.location.longitude),
            "capacity" : self.capacity,
            "visibility" : self.visibility,
            "tags" : self.tags
        ]
        
        return information
    }
    
    func saveEvent() {
        
        let db = Firestore.firestore()
        
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("events").addDocument(data: [
            "creator_username":  self.creator_username,
            "information": generate_information_map(),
            "attendees": self.attendees
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func updateEvent() {
    
    
    if let id = self.documentID {
        let db = Firestore.firestore()
        let data = [
            "creator_username":  self.creator_username,
            "information": generate_information_map(),
            "attendees": self.attendees
            ] as [String : Any]
        
        db.collection("events").document(id).setData(data) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully updated!")
            }
        }

        
        
        
    } else {
    print("Error, no ID saved...")
    }
    
    }
}
