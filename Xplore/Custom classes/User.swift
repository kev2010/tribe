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

class User {
    
    var username : String
    var name : String
    var email : String
    var DOB : Date
    var currentLocation : CLLocationCoordinate2D?
    var currentEvent : String?
    var isPrivate : Bool
    var friends : [String]
    var blocked : [String]
    var eventsUserHosted : [String]
    var eventsUserAttended : [String]
    var eventsUserBookmarked : [String]
    var documentID : String?
    
    

    
    init(username:String, name:String, email:String, DOB:Date, currentLocation:CLLocationCoordinate2D?, currentEvent:String?, isPrivate:Bool, friends:[String], blocked:[String], eventsUserHosted:[String], eventsUserAttended:[String], eventsUserBookmarked:[String]) {
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
    
    func updateUser(dictToUpdate dict : [String:Any]) {
        
        var data : [String:Any] = [:]
        
        for datapoint in dict {
            
            
            switch datapoint.key {
                
            case "name":
                data["user_information.name"] = dict[datapoint.key] as! String
                self.name = dict[datapoint.key] as! String
                
            case "email":
                data["user_information.email"] = dict[datapoint.key] as! String
                
            case "dob":
                data["user_information.dob"] = Timestamp(date: dict[datapoint.key] as! Date)
                
            case "current_location":
                if let loc = dict[datapoint.key] as? CLLocationCoordinate2D {
                    data["user_information.current_location"] = GeoPoint(latitude: loc.latitude, longitude: loc.longitude)
                } else {
                    data["user_information.current_location"] = nil
                }
                
            case "current_event":
                if let event = dict[datapoint.key] as? String {
                data["user_information.current_event"] = event
                } else {
                    data["user_information.current_event"] = nil
                }
                
            case "is_private":
                data["user_information.is_private"] = dict[datapoint.key] as! Bool
                
            case "friends":
                data["social.friends"] = dict[datapoint.key] as! [String]
                
                
            case "blocked":
                data["social.blocked"] = dict[datapoint.key] as! [String]

            case "events_user_hosted":
                data["events.events_user_hosted"] = dict[datapoint.key] as! [String]
                
                
            case "events_used_attended":
                data["events.events_used_attended"] = dict[datapoint.key] as! [String]
                
                
            case "events_user_bookmarked":
                data["events.events_user_bookmarked"] = dict[datapoint.key] as! [String]
                
            default:
                print("ERROR, unknown key")
                assert(false)
                
                
                
            }
        }
        
        let db = Firestore.firestore()

        db.collection("users").document(self.username).updateData(data) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    func updateField(key:String, value:Any) {
        let db = Firestore.firestore()
        
        db.collection("users").document(self.username).updateData([
            key: value
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
}
