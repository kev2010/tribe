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
    
    var uid : String
    var username : String
    var name : String
    var email : String
    var DOB : Date
    var currentLocation : CLLocationCoordinate2D // (0,0) if location unavailable
    var currentEvent : [DocumentReference] // []] if no event
    var isPrivate : Bool
    var friends : [DocumentReference]
    var blocked : [DocumentReference]
    var eventsUserHosted : [DocumentReference]
    var eventsUserAttended : [DocumentReference]
    var eventsUserBookmarked : [DocumentReference]
    var documentID : String?
    var infoDictionary : [String:Any]
    
    
    init(uid:String, username:String, name:String, email:String, DOB:Date, currentLocation:CLLocationCoordinate2D, currentEvent:[DocumentReference], isPrivate:Bool, friends:[DocumentReference], blocked:[DocumentReference], eventsUserHosted:[DocumentReference], eventsUserAttended:[DocumentReference], eventsUserBookmarked:[DocumentReference]) {
        self.uid = uid
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
        
        self.infoDictionary = [
            "uid" : uid,
            "username" : username,
            "name" : name,
            "email": email,
            "dob": DOB,
            "current_location" : currentLocation,
            "current_event" : currentEvent,
            "is_private" : isPrivate,
            "friends" : friends,
            "blocked" : blocked,
            "events_user_hosted" : eventsUserHosted,
            "events_user_attended" : eventsUserAttended,
            "events_user_bookmarked" : eventsUserBookmarked
            ] as [String:Any]
        
    }
    
    init(QueryDocumentSnapshot file: QueryDocumentSnapshot) {
        /**
         USAGE: Use this initialiser to load in a file (QueryDocumentSnapshot) that is retrieved from the cloud.
         Once initialised this way, self.saveEvent() should not be used,
         and instead, self.updateEvent() should be called whenever necessary
         **/
        
        let data = file.data()
        
        self.documentID = file.documentID
        
        let user_info = data["user_information"] as! [String:Any]
        let social = data["social"] as! [String:Any]
        let events = data["evemts"] as! [String:Any]
        
        self.uid = user_info["uid"] as! String
        self.username = user_info["username"] as! String
        self.name = user_info["name"] as! String
        self.email = user_info["email"] as! String
        self.DOB = (user_info["dob"] as! Timestamp).dateValue()
        let loc = user_info["current_location"] as! GeoPoint
        self.currentLocation = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        self.currentEvent = user_info["current_event"] as! [DocumentReference]
        self.isPrivate = user_info["is_private"] as! Bool
        
        self.friends = social["friends"] as! [DocumentReference]
        self.blocked = social["blocked"] as! [DocumentReference]
        
        self.eventsUserHosted = events["events_user_hosted"] as! [DocumentReference]
        self.eventsUserAttended = events["events_user_attended"] as! [DocumentReference]
        self.eventsUserBookmarked = events["events_user_bookmarked"] as! [DocumentReference]
        
        self.infoDictionary = [
            "uid" : user_info["uid"] as! String,
            "username" : user_info["username"] as! String,
            "name" : user_info["name"] as! String,
            "email": user_info["email"] as! String,
            "dob": (user_info["dob"] as! Timestamp).dateValue(),
            "current_location" : CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude),
            "current_event" : user_info["current_event"] as! DocumentReference,
            "is_private" : user_info["is_private"] as! Bool,
            "friends" :  social["friends"] as! [DocumentReference],
            "blocked" : social["blocked"] as! [DocumentReference],
            "events_user_hosted" : events["events_user_hosted"] as! [DocumentReference],
            "events_user_attended" : events["events_user_attended"] as! [DocumentReference],
            "events_user_bookmarked" : events["events_user_bookmarked"] as! [DocumentReference]
            ] as [String:Any]
        
    }
    
    init(DocumentSnapshot file: DocumentSnapshot) {
        //assumes the file exists
        
        let data = file.data()!
        
        self.documentID = file.documentID
        
        let user_info = data["user_information"] as! [String:Any]
        let social = data["social"] as! [String:Any]
        let events = data["events"] as! [String:Any]
        
        self.uid = user_info["uid"] as! String
        self.username = user_info["username"] as! String
        self.name = user_info["name"] as! String
        self.email = user_info["email"] as! String
        self.DOB = (user_info["dob"] as! Timestamp).dateValue()
        let loc = user_info["current_location"] as! GeoPoint
        self.currentLocation = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        self.currentEvent = user_info["current_event"] as! [DocumentReference]
        self.isPrivate = user_info["is_private"] as! Bool
        
        self.friends = social["friends"] as! [DocumentReference]
        self.blocked = social["blocked"] as! [DocumentReference]
        
        self.eventsUserHosted = events["events_user_hosted"] as! [DocumentReference]
        self.eventsUserAttended = events["events_used_attended"] as! [DocumentReference]
        self.eventsUserBookmarked = events["events_user_bookmarked"] as! [DocumentReference]
        
        self.infoDictionary = [
            "uid" : self.uid,
            "username" : self.username,
            "name" : self.name,
            "email": self.email,
            "dob": self.DOB,
            "current_location" : self.currentLocation,
            "current_event" : self.currentEvent,
            "is_private" : self.isPrivate,
            "friends" :  self.friends,
            "blocked" : self.blocked,
            "events_user_hosted" : self.eventsUserHosted,
            "events_user_attended" : self.eventsUserAttended,
            "events_user_bookmarked" : self.eventsUserBookmarked
            ] as [String:Any]
        
    }
    
    func dictionary() -> [String:Any]{
        return [
            "uid" : self.uid,
            "username" : self.username,
            "name" : self.name,
            "email": self.email,
            "dob": self.DOB,
            "current_location" : self.currentLocation,
            "current_event" : self.currentEvent,
            "is_private" : self.isPrivate,
            "friends" : self.friends,
            "blocked" : self.blocked,
            "events_user_hosted" : self.eventsUserHosted,
            "events_user_attended" : self.eventsUserAttended,
            "events_user_bookmarked" : self.eventsUserBookmarked
            ] as [String:Any]
    }
    
    func generate_userInformation_map(db: Firestore) -> [String:Any] {
        return [
            "uid" : self.uid,
            "username" : self.username,
            "name" : self.name,
            "email" : self.email,
            "dob" : Timestamp(date: self.DOB),
            "current_location" : GeoPoint(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude),
            "current_event" : self.currentEvent,
//            "current_event" : (self.currentEvent != "" ? db.document("events/\(self.currentEvent)") : "") ,
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
        
        // Add a new document with username as Document ID
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
    
    func updateUser() {
        
        
        var data : [String:Any] = [:]
        
        for key in self.infoDictionary.keys {
            
            
            switch key {
            
            case "uid":
                if self.infoDictionary[key] as! String != self.uid {
                    data["user_information.uid"] = self.uid
                }
                
            case "username":
                if self.infoDictionary[key] as! String != self.username {
                    data["user_information.username"] = self.username
                }
                
            case "name":
                if self.infoDictionary[key] as! String != self.name {
                    data["user_information.name"] = self.name
                }
                
            case "email":
                if self.infoDictionary[key] as! String != self.email {
                    data["user_information.email"] = self.email
                }
            case "dob":
                if self.infoDictionary[key] as! Date != self.DOB {
                    data["user_information.dob"] = Timestamp(date: self.DOB)
                }
                
            case "current_location":
                
                if !((self.infoDictionary[key] as! CLLocationCoordinate2D).latitude == self.currentLocation.latitude && (self.infoDictionary[key] as! CLLocationCoordinate2D).longitude == self.currentLocation.longitude)  {
                    data["user_information.current_location"] = GeoPoint(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude)
                }
                
                
            case "current_event":
                if self.infoDictionary[key] as! [DocumentReference] != self.currentEvent {
                    data["user_information.current_event"] = self.currentEvent
                }
                
                
            case "is_private":
                if self.infoDictionary[key] as! Bool != self.isPrivate {
                    data["user_information.is_private"] = self.isPrivate
                }
                
            case "friends":
                if self.infoDictionary[key] as! [DocumentReference] != self.friends {
                    data["social.friends"] = self.friends
                }
                
            case "blocked":
                if self.infoDictionary[key] as! [DocumentReference] != self.blocked {
                    data["social.blocked"] = self.blocked
                }
                
            case "events_user_hosted":
                if self.infoDictionary[key] as! [DocumentReference] != self.eventsUserHosted {
                    data["events.events_user_hosted"] = self.eventsUserHosted
                }
                
            case "events_used_attended", "events_user_attended":
                if self.infoDictionary[key] as! [DocumentReference] != self.eventsUserAttended {
                    data["events.events_used_attended"] = eventsUserAttended
                }
                
            case "events_user_bookmarked":
                if self.infoDictionary[key] as! [DocumentReference] != self.eventsUserBookmarked {
                    data["events.events_user_bookmarked"] = self.eventsUserBookmarked
                }
                
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
                self.infoDictionary = self.dictionary()
            }
        }
    }
    
    
}
