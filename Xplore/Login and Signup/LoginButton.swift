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
        self.layer.cornerRadius = CGFloat(integerLiteral: 13)  //  Not working?
//        self.titleLabel?.font = UIFont(name: "TrebuchetMSBold", size: 24)
        self.addGradientLayer(topColor: UIColor(displayP3Red: 0/255, green: 255/255, blue: 179/255, alpha: 1), bottomColor: UIColor(displayP3Red: 0/255, green: 255/255, blue: 255/255, alpha: 1))
    }
    
}

