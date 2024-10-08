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
            
            if let description = eventItem.event?.description {
                descriptionLabel.text = description
            }
            
            if let start = eventItem.event?.startDate {
                if let end = eventItem.event?.endDate {
                    let calendar = Calendar.current
                    
                    var shour = String(calendar.component(.hour, from: start) % 12)
                    if shour == "0" {
                        shour = "12"
                    }
                    var smin : String
                    if (calendar.component(.minute, from: start) == 0) {
                        smin = "00"
                    } else if (calendar.component(.minute, from: start) < 10) {
                        smin = "0" + String(calendar.component(.minute, from: start))
                    } else {
                        smin = String(calendar.component(.minute, from: start))
                    }
                    let speriod = (Int(shour)! > 12) ? "PM" : "AM"
                    
                    var ehour = String(calendar.component(.hour, from: end) % 12)
                    if ehour == "0" {
                        ehour = "12"
                    }
                    var emin : String
                    if (calendar.component(.minute, from: end) == 0) {
                        emin = "00"
                    } else if (calendar.component(.minute, from: end) < 10) {
                        emin = "0" + String(calendar.component(.minute, from: end))
                    } else {
                        emin = String(calendar.component(.minute, from: end))
                    }
                    let eperiod = (Int(ehour)! > 12) ? "PM" : "AM"
                    
                    timeLabel.text = shour + ":" + smin + " " + speriod + " - " + ehour + ":" + emin + " " + eperiod
                }
            }
        }
    }
    
    //  Container for Name label and Current Event
//    let containerView:UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.clipsToBounds = true // this will make sure its children do not go out of the boundary
//        return view
//    }()
    
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
    let descriptionLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor =  .lightGray
//        label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //  Name of event friend is attending (if any)
    let locationLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor =  .black
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
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // configure nameLabel
        contentView.addSubview(nameLabel)
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        nameLabel.numberOfLines = 0
//        nameLabel.font = UIFont.systemFont(ofSize: 16)
        
        contentView.addSubview(timeLabel)
        timeLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
//        timeLabel.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        
        contentView.addSubview(locationLabel)
        locationLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor).isActive = true
        locationLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        
        // configure detailLabel
        contentView.addSubview(descriptionLabel)
        descriptionLabel.lineBreakMode = .byWordWrapping
//        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5).isActive = true
        descriptionLabel.numberOfLines = 0
//        locationLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = UIColor.lightGray
        
        
//        self.contentView.isUserInteractionEnabled = false
        
        //  Add all the views to Friends TableView
//        self.contentView.addSubview(profileImageView)
//        containerView.addSubview(nameLabel)
//        self.contentView.addSubview(containerView)
//        self.contentView.addSubview(locationLabel)
//        self.contentView.addSubview(timeLabel)
        
        //  Add constraints to profile image
//        profileImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
//        profileImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
//        profileImageView.widthAnchor.constraint(equalToConstant:70).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant:70).isActive = true
        
        //  containerview auto layout constraints
//        containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
//        containerView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
////        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-10).isActive = true
//        containerView.heightAnchor.constraint(equalToConstant:40).isActive = true
        
//        timeLabel.widthAnchor.constraint(equalToConstant:26).isActive = true
//        timeLabel.heightAnchor.constraint(equalToConstant:26).isActive = true
//        timeLabel.leadingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-150).isActive = true
//        timeLabel.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-20).isActive = true
//        timeLabel.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        
        //  name label auto layout constraints
//        nameLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
//        nameLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
//        nameLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        
        
        //  current event label auto layout constraints
//        locationLabel.lineBreakMode = .byWordWrapping
//        locationLabel.translatesAutoresizingMaskIntoConstraints = false
//        locationLabel.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor).isActive = true
//        locationLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
//        locationLabel.trailingAnchor.constraint(equalTo:self.timeLabel.leadingAnchor, constant: -20).isActive = true
//        locationLabel.numberOfLines = 0
        
     }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
}
