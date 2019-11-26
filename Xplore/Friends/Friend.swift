//
//  Friend.swift
//  Xplore
//
//  Created by Kevin Jiang on 9/7/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

struct Friend {
    let picture: UIImage?
    let user: User?
//    let name: String?
    let currentEvent: String?
    var annotation : MGLAnnotation?
}
