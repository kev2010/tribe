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
            
            if let address = eventItem.event?.address {
                locationLabel.text = address
            }
            
            if let start = eventItem.event?.startDate {
                if let end = eventItem.event?.endDate {
                    let calendar = Calendar.current
                    
                    let shour = String(calendar.component(.hour, from: start) % 12)
                    let smin = (calendar.component(.minute, from: start) == 0) ? "00" : String(calendar.component(.minute, from: start))
                    let speriod = (Int(shour)! > 12) ? "PM" : "AM"
                    
                    let ehour = String(calendar.component(.hour, from: end) % 12)
                    let emin = (calendar.component(.minute, from: end) == 0) ? "00" : String(calendar.component(.minute, from: end))
                    let eperiod = (Int(ehour)! > 12) ? "PM" : "AM"
                    
                    timeLabel.text = shour + ":" + smin + " " + speriod + " - " + ehour + ":" + emin + " " + eperiod
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
       return img
    }()
    
    //  Name of friend
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //  Name of event friend is attending (if any)
    let locationLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor =  .lightGray
//        label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let timeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
//        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        self.contentView.isUserInteractionEnabled = false
        
        //  Add all the views to Friends TableView
//        self.contentView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        self.contentView.addSubview(containerView)
        self.contentView.addSubview(locationLabel)
        self.contentView.addSubview(timeLabel)
        
        //  Add constraints to profile image
//        profileImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
//        profileImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
//        profileImageView.widthAnchor.constraint(equalToConstant:70).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant:70).isActive = true
        
        //  containerview auto layout constraints
        containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
//        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-10).isActive = true
        containerView.heightAnchor.constraint(equalToConstant:40).isActive = true
        
        //  name label auto layout constraints
        nameLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        
        //  current event label auto layout constraints
        locationLabel.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor).isActive = true
        locationLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        
        
//        timeLabel.widthAnchor.constraint(equalToConstant:26).isActive = true
//        timeLabel.heightAnchor.constraint(equalToConstant:26).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-20).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
     }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
}
