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
    
    let creator_username : String
    let avatar :  UIImage?
    let title  : String
    let description : String
    let startDate : Date
    let endDate : Date
    let location : CLLocationCoordinate2D
    let capacity : Int
    let visibility : String
    let tags : [String]
    let attendees : [String]
    
    
    
    init(creator_username:String, avatar:UIImage?, title:String, description:String, startDate:Date, endDate: Date, location: CLLocationCoordinate2D, capacity:Int, visibility:String, tags:[String], attendees:[String]) {
        self.creator_username = creator_username
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
            "creator_username":  db.document("users/\(self.creator_username)"),
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
    
}
