//
//  AddFriendCell.swift
//  Xplore
//
//  Created by Kevin Jiang on 10/28/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit

class AddFriendCell: UITableViewCell {
    //  Initializers for friend cell
    var friend:Friend? {
        didSet {
            guard let friendItem = friend else {return}
            if let picture = friendItem.picture {
                profileImageView.image = picture
            }
            
            if let name = friendItem.user?.username {
                nameLabel.text = name
            }
        }
    }
    
    //  Profile picture for each friend
    let profileImageView:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.layer.cornerRadius = 35
        img.clipsToBounds = true
       return img
    }()
    
    //  Name of friend
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "Futura-Bold", size: 18)
        label.textColor = .black
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //  Left button (either to accept a friend request or nothing)
    let leftButton:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "addUser"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    //  Right button (either to reject a friend or to send friend request)
    //  TODO: Code repeated from leftButton, make it DRY
    let rightButton:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "addUser"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //  Add all the views to Friends TableView
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(leftButton)
        self.contentView.addSubview(rightButton)
        
        //  Add constraints to profile image
        profileImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:20).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant:70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant:70).isActive = true
        
        //  name label auto layout constraints
        nameLabel.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo:self.profileImageView.trailingAnchor, constant:  10).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-10).isActive = true
        
        //  leftButton auto layout constraints
        leftButton.widthAnchor.constraint(equalToConstant:70).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant:70).isActive = true
        leftButton.trailingAnchor.constraint(equalTo:self.rightButton.trailingAnchor, constant:-90).isActive = true
        leftButton.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        
        //  rightButton auto layout constraints
        rightButton.widthAnchor.constraint(equalToConstant:70).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant:70).isActive = true
        rightButton.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-20).isActive = true
        rightButton.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
     }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
}
