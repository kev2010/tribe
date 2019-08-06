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
        self.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
        self.addGradientLayer(topColor: UIColor(displayP3Red: 51/255, green: 1, blue: 1, alpha: 1), bottomColor: UIColor(displayP3Red: 56/255, green: 140/255, blue: 140/255, alpha: 1))
    }
    
}

