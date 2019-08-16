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
    
    var infoDictionary : [String:Any]
    
    init(creator_username:String, title:String, description:String, startDate:Date, endDate: Date, location: CLLocationCoordinate2D, capacity:Int, visibility:String, tags:[String], attendees:[String]) {
        /**
         USAGE: This initialiser should be used to create a completely new event.
         After creating the event, self.saveEvent() should be called once,
         after which self.updateEvent() should be used whenever necessary.
         **/
        
        let db = Firestore.firestore()
        
        self.creator_username = db.document("users/\(creator_username)")
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
        
        self.infoDictionary = [
            "creator_username" : self.creator_username,
            "title": self.title,
            "description": self.description,
            "startDate" : Timestamp(date: self.startDate),
            "endDate"  : Timestamp(date: self.endDate),
            "location" : GeoPoint(latitude: self.location.latitude, longitude: self.location.longitude),
            "capacity" : self.capacity,
            "visibility" : self.visibility,
            "tags" : self.tags,
            "attendees" : self.attendees
        ]
    }
    
    init(QueryDocumentSpapshot file: QueryDocumentSnapshot) {
        /**
         USAGE: Use this initialiser to load in a file (QueryDocumentSnapshot) that is retrieved from the cloud.
         Once initialised this way, self.saveEvent() should not be used,
         and instead, self.updateEvent() should be called whenever necessary
         **/
        
        let data = file.data()
        
        self.documentID = file.documentID
        
        self.creator_username = data["creator_username"] as! DocumentReference
        
        let information = data["information"] as! [String:Any]
        
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
        
        self.infoDictionary = [
            "creator_username" : self.creator_username,
            "title": self.title,
            "description": self.description,
            "startDate" : Timestamp(date: self.startDate),
            "endDate"  : Timestamp(date: self.endDate),
            "location" : GeoPoint(latitude: self.location.latitude, longitude: self.location.longitude),
            "capacity" : self.capacity,
            "visibility" : self.visibility,
            "tags" : self.tags,
            "attendees" : self.attendees
        ]
    }
    
    init(DocumentSnapshot file: DocumentSnapshot) {
        /**
         USAGE: Use this initialiser to load in a file (QueryDocumentSnapshot) that is retrieved from the cloud.
         Once initialised this way, self.saveEvent() should not be used,
         and instead, self.updateEvent() should be called whenever necessary
         **/
        
        let data = file.data()!
        
        self.documentID = file.documentID
        
        self.creator_username = data["creator_username"] as! DocumentReference
        
        let information = data["information"] as! [String:Any]
        
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
        
        self.infoDictionary = [
            "creator_username" : self.creator_username,
            "title": self.title,
            "description": self.description,
            "startDate" : Timestamp(date: self.startDate),
            "endDate"  : Timestamp(date: self.endDate),
            "location" : GeoPoint(latitude: self.location.latitude, longitude: self.location.longitude),
            "capacity" : self.capacity,
            "visibility" : self.visibility,
            "tags" : self.tags,
            "attendees" : self.attendees
        ]
    }
    
    
    func generate_information_map() -> [String:Any] {
        // INTERNAL
        
        let information : [String:Any] = [
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
        /**
         USAGE: Save event should be called ONCE, after having initialised a new Event object.
         Calling this multiple times will create separate events in the cloud.
         **/
        
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
    
    func dictionary() -> [String:Any]{
        //INTERNAL
        
        return[
            "creator_username" : self.creator_username,
            "title": self.title,
            "description": self.description,
            "startDate" : Timestamp(date: self.startDate),
            "endDate"  : Timestamp(date: self.endDate),
            "location" : GeoPoint(latitude: self.location.latitude, longitude: self.location.longitude),
            "capacity" : self.capacity,
            "visibility" : self.visibility,
            "tags" : self.tags,
            "attendees" : self.attendees
            ] as [String:Any]
    }
    
    func updateEvent() {
        /**
         USAGE: updateEvent() should be called after changing instance variables in the Event class.
         For example, after changing the capacity to event1.capacity = 20, updateEvent() should be called so that it is saved in the cloud.
         **/
        
        var data : [String:Any] = [:]
        
        for key in self.infoDictionary.keys {
            
            switch key {
                
            case "creator_username":
                if self.infoDictionary[key] as! DocumentReference != self.creator_username {
                    data["creator_username"] = self.creator_username
                }
                
            case "title":
                if self.infoDictionary[key] as! String != self.title {
                    data["information.title"] = self.title
                }
                
            case "description":
                if self.infoDictionary[key] as! String != self.description {
                    data["information.description"] = self.description
                }
            case "startDate":
                if self.infoDictionary[key] as! Date != self.startDate {
                    data["information.startDate"] = Timestamp(date: self.startDate)
                }
                
            case "endDate":
                if self.infoDictionary[key] as! Date != self.endDate {
                    data["information.endDate"] = Timestamp(date: self.endDate)
                }
                
            case "location":
                
                if !((self.infoDictionary[key] as! CLLocationCoordinate2D).latitude == self.location.latitude && (self.infoDictionary[key] as! CLLocationCoordinate2D).longitude == self.location.longitude)  {
                    data["information.location"] = GeoPoint(latitude: self.location.latitude, longitude: self.location.longitude)
                }
                
            case "capacity":
                if self.infoDictionary[key] as! Int != self.capacity {
                    data["information.capacity"] = self.capacity
                }
                
            case "visibility":
                if self.infoDictionary[key] as! String != self.visibility {
                    data["information.visibility"] = self.visibility
                }
                
            case "tags":
                if self.infoDictionary[key] as! [String] != self.tags {
                    data["information.tags"] = self.tags
                }
                
            case "attendees":
                if self.infoDictionary[key] as! [String] != self.attendees {
                    data["attendees"] = self.attendees
                }
                
            default:
                print("ERROR, unknown key")
                assert(false)// TODO : remove there
            }
        }
        
        let db = Firestore.firestore()
        
        if self.documentID == nil {
            self.saveEvent()
            return
        }
        
        db.collection("events").document(self.documentID!).updateData(data) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                self.infoDictionary = self.dictionary()
            }
        }
    }
    
}
