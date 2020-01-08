//
//  LoginButton.swift
//  Xplore
//
//  Created by Kevin Jiang on 8/6/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit

class LoginButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureUI()
    }
    
    private func configureUI() {
        //  add gradient to button
        self.layer.cornerRadius = CGFloat(15.0)  //  Not working?
        self.clipsToBounds = true
//        let color1 = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
//        let color2 = UIColor(red: 58/255, green: 68/255, blue: 84/255, alpha: 1)
        //        let color2 = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
//        self.addGradientLayer(topColor: color1, bottomColor: color2)
    }
    
}



