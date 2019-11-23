//
//  SearchCell.swift
//  Xplore
//
//  Created by Kevin Jiang on 11/23/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    
    //  Initializers for friend cell
    var event:Search? {
        didSet {
            guard let eventItem = event else {return}
            
            if let name = eventItem.event?.title {
                nameLabel.text = name
            }
            
            if let location = eventItem.event?.location {
//                //First Convert it to NSNumber.
//                let lat : NSNumber = NSNumber(value: location.latitude)
//                let lng : NSNumber = NSNumber(value: location.longitude)
//
//                //Store it into Dictionary
//                let locationDict = ["lat": lat, "lng": lng]
//
//                //Store that Dictionary into NSUserDefaults
//                UserDefaults.standard.set(locationDict, forKey: "Location")
                
                locationLabel.text = String(location.latitude) + " " + String(location.longitude)
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
    
    //  Name of event friend is attending (if any)
    let locationLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor =  .white
        label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        self.contentView.isUserInteractionEnabled = false
        
        //  Add all the views to Friends TableView
        self.contentView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        self.contentView.addSubview(containerView)
        self.contentView.addSubview(locationLabel)
        
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
        locationLabel.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor).isActive = true
        locationLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
     }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
}
