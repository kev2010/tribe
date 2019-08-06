//
//  User.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 06/08/2019.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import Foundation
import Mapbox
import Firebase

class  User {
    
    let username : String
    let name : String
    let email : String
    let DOB : Date
    let currentLocation : CLLocationCoordinate2D?
    let currentEvent : String?
    let isPrivate : Bool?
    let friends : [String]
    let blocked : [String]
    let eventsUserHosted : [String]
    let eventsUserAttended : [String]
    let eventsUserBookmarked : [String]
    
    init(username:String, name:String, email:String, DOB:Date, currentLocation:CLLocationCoordinate2D?, currentEvent:String?, isPrivate:Bool?, friends:[String], blocked:[String], eventsUserHosted:[String], eventsUserAttended:[String], eventsUserBookmarked:[String]) {
        self.username = username
        self.name = name
        self.email = email
        self.DOB = DOB
        self.currentLocation = currentLocation
        self.currentEvent = currentEvent
        self.isPrivate  = isPrivate
        self.friends = friends
        self.blocked = blocked
        self.eventsUserHosted = eventsUserHosted
        self.eventsUserAttended = eventsUserAttended
        self.eventsUserBookmarked  = eventsUserBookmarked
    }
    
    func generate_userInformation_map(db: Firestore) -> [String:Any] {
        return [
            "username": self.username,
            "name" : self.name,
            "email" : self.email,
            "dob" : Timestamp(date: self.DOB),
            "current_location" : (self.currentLocation != nil ? GeoPoint(latitude: self.currentLocation!.latitude, longitude: self.currentLocation!.longitude) : nil)!,
            "current_event" : (self.currentEvent != nil ? db.document("events/\(self.currentEvent!)") : nil)!,
            "is_private" : self.isPrivate
        ]
    }
    
    func generate_social_map() -> [String:Any] {
        return [
            "friends": self.friends,
            "blocked" : self.blocked
        ]
    }
    
    func generate_events_map() -> [String:Any] {
        return [
            "events_user_hosted": self.eventsUserHosted,
            "events_used_attended": self.eventsUserAttended,
            "events_user_bookmarked": self.eventsUserBookmarked
        ]
    }
    
    func saveUser() {
        let db = Firestore.firestore()
        
        // Add a new document with a generated ID
        db.collection("users").document(self.username).setData([
            "user_information":  generate_userInformation_map(db: db),
            "social": generate_social_map(),
            "events": generate_events_map()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.username)")
            }
        }

    }
    
    
    
}
