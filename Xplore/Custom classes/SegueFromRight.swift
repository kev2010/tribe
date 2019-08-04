//
//  SegueFromRight.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 04/08/2019.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import Foundation
import UIKit

class SegueFromRight: UIStoryboardSegue {
    
    override func perform() {
        let src = self.source
        let dst = self.destination
        
//        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        src.view.superview?.insertSubview(dst.view, belowSubview: src.view)

        //        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
//                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                        src.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)

        },
                       completion: { finished in
                        src.present(dst, animated: false, completion: nil)
        }
        )
    }
}

