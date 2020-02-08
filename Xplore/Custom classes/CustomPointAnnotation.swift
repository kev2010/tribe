//
//  CustomPointAnnotation.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 04/08/2019.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import Foundation
import Mapbox

class CustomPointAnnotation: NSObject, MGLAnnotation {
    // As a reimplementation of the MGLAnnotation protocol, we have to add mutable coordinate and (sub)title properties ourselves.
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var desc: String?
    var event_id : String?
    var bm : Bool?
    
    // Custom properties that we will use to customize the annotation's image.
    var image: UIImage?
    var reuseIdentifier: String?
    
    var type : AnnotationType
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, description: String?, annotationType:AnnotationType, event_id:String?, bm:Bool?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.desc = description
        self.type = annotationType
        self.event_id = event_id
        self.bm = bm
    }
}
