//
//  SettingsCell.swift
//  Xplore
//
//  Created by Kevin Jiang on 9/20/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    // MARK: - Properties
    
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
//            switchControl.isHidden = !sectionType.containsSwitch
        }
    }
    
//    lazy var switchControl: UISwitch = {
//        let switchControl = UISwitch()
//        switchControl.isOn = currentUser!.isPrivate
//        switchControl.onTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
//        switchControl.translatesAutoresizingMaskIntoConstraints = false
//        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
//        return  switchControl
//    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        addSubview(switchControl)
//        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
//    @objc func handleSwitchAction(sender: UISwitch) {
//        if sender.isOn {
//            currentUser?.isPrivate = true
//        } else {
//            currentUser?.isPrivate = false
//        }
//    }
    
}
