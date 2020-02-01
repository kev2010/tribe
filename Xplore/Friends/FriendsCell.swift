//
//  FriendsCell.swift
//  Xplore
//
//  Created by Kevin Jiang on 10/5/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {
    
    //  Initializers for friend cell
    var friend:Friend? {
        didSet {
            guard let friendItem = friend else {return}
            if let picture = friendItem.picture {
                profileImageView.image = picture
            }
            
            if let name = friendItem.user?.name {
                nameLabel.text = name
            }
            if let currentEvent = friendItem.currentEvent {
                if currentEvent != "" {
                    currentEventLabel.text = " \(currentEvent) "
                }
            }
        }
    }
    
    //  Container for Name label and Current Event
    let containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true // this will make sure its children do not go out of the boundary
        return view
    }()
    
    //  Profile picture for each friend
    let profileImageView:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.layer.cornerRadius = 35
        img.clipsToBounds = true
        print("uh oh!!!!")
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
    
    //  Name of event friend is attending (if any)
    let currentEventLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Bold", size: 14)
        label.textColor =  UIColor.init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
//        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //  Add all the views to Friends TableView
        self.contentView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(currentEventLabel)
        self.contentView.addSubview(containerView)
        
        //  Add constraints to profile image
        profileImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant:70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant:70).isActive = true
        
        //  containerview auto layout constraints
        containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.profileImageView.trailingAnchor, constant:10).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-10).isActive = true
        containerView.heightAnchor.constraint(equalToConstant:45).isActive = true
        
        //  name label auto layout constraints
        nameLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        
        //  current event label auto layout constraints
        currentEventLabel.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor, constant: 0).isActive = true
        currentEventLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
     }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
}
