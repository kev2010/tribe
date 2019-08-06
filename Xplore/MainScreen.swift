//
//  MainScreen.swift
//  Xplore
//
//  Created by Kevin Jiang on 7/31/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Mapbox
import Firebase

class MainScreen: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradientLayer(topColor: UIColor(displayP3Red: 27/255, green: 27/255, blue: 131/255, alpha: 1), bottomColor: UIColor(displayP3Red: 44/255, green: 44/255, blue: 129/255, alpha: 1))
        
    }
    
    @IBAction func tomap(_ sender: Any) {

        let transition: CATransition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)

    }
    
    @IBAction func logoutTap(_ sender: UIButton) {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "mainToMenu", sender: self)
    }
    
}

