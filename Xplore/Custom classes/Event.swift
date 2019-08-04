//
//  Event.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 04/08/2019.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import Foundation
import Mapbox
class Event {
    
    let name : String
    let coordinates : CLLocationCoordinate2D
    let numPeople : Int
    let desc : String
    
    init(name:String, coordinates:CLLocationCoordinate2D, numPeople:Int, description:String) {
        self.name = name
        self.coordinates = coordinates
        self.numPeople = numPeople
        self.desc = description
    }
    
}
