//
//  PushNoAnimationSegue.swift
//  Xplore
//
//  Created by Kevin Jiang on 3/6/20.
//  Copyright © 2020 Kevin Jiang. All rights reserved.
//

import UIKit

class PushNoAnimationSegue: UIStoryboardSegue {

    override func perform() {
        self.source.navigationController?.pushViewController(self.destination, animated: false)
    }
}
