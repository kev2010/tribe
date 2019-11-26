//
//  RoundedButton.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 26/11/2019.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    var selectedState: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 2 / UIScreen.main.nativeScale
        layer.borderColor = UIColor.white.cgColor
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }


    override func layoutSubviews(){
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        backgroundColor = selectedState ? UIColor.white : UIColor.clear
        self.titleLabel?.textColor = selectedState ? UIColor.green : UIColor.white
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedState = !selectedState
        self.layoutSubviews()
    }
}
