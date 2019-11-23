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
       return img
    }()
    
    //  Name of friend
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let addButton:UIButton = {
        let btn = UIButton()
//        btn.setTitle("+", for: UIControl.State.normal)
//        btn.titleLabel!.font = UIFont(name: "GeezaPro-Bold", size: 42)
//        btn.titleLabel?.textAlignment = .center
//        btn.titleLabel?.textColor = .black
        btn.setImage(UIImage(named: "add"), for: UIControl.State.normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
//        btn.layer.cornerRadius = 13
//        btn.clipsToBounds = true
        print("woahhhh")
        return btn
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        self.contentView.isUserInteractionEnabled = false
        
        //  Add all the views to Friends TableView
        self.contentView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        self.contentView.addSubview(containerView)
        self.contentView.addSubview(addButton)
        
        //  Add constraints to profile image
        profileImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant:70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant:70).isActive = true
        
        //  containerview auto layout constraints
        containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.profileImageView.trailingAnchor, constant:10).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-10).isActive = true
        containerView.heightAnchor.constraint(equalToConstant:40).isActive = true
        
        //  name label auto layout constraints
        nameLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        
        //  current event label auto layout constraints
        addButton.widthAnchor.constraint(equalToConstant:26).isActive = true
        addButton.heightAnchor.constraint(equalToConstant:26).isActive = true
        addButton.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-20).isActive = true
        addButton.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
     }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
}
