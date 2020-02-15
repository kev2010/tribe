//
//  BookmarkCell.swift
//  Xplore
//
//  Created by Kevin Jiang on 10/21/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit

class BookmarkCell: UITableViewCell {
    
    //  Initializers for bookmark cell
    var bookmark:Bookmark? {
        didSet {
            guard let bookmarkItem = bookmark else {return}
//            if let picture = bookmarkItem.picture {
//                eventImageView.image = picture
//            }
            
            if let title = bookmarkItem.event?.title {
                titleLabel.text = title
            }
            
//            if let creator = bookmarkItem.creator {
//                creatorLabel.text = creator
//            }
            
            if let description = bookmarkItem.event?.description {
                descriptionLabel.text = description
            }
            
        }
    }
    
    //  Container for title label and creator label
    let containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true // this will make sure its children do not go out of the boundary
        return view
    }()
    
    //  Event icon for each event
    let eventImageView:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.layer.cornerRadius = 35
        img.clipsToBounds = true
       return img
    }()
    
    //  Title of Event
    let titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Bold", size: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 5
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    //  Username of creator
//    let creatorLabel:UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 12)
//        label.textColor =  .white
////        label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
////        label.layer.cornerRadius = 5
////        label.clipsToBounds = true
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
    let descriptionLabel:UILabel = {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 1000))
        label.font = UIFont(name: "Futura-Bold", size: 12)
        label.textColor =  .white
        label.textAlignment = .left
//        label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
//        label.layer.cornerRadius = 5
//        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 5
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    //  TODO: Date of event

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //  Add all the views to Bookmarks TableView
        self.contentView.addSubview(eventImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        self.contentView.addSubview(containerView)
        
        //  Add constraints to event image
//        eventImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
//        eventImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
//        eventImageView.widthAnchor.constraint(equalToConstant:70).isActive = true
//        eventImageView.heightAnchor.constraint(equalToConstant:70).isActive = true
        
        //  containerview auto layout constraints
        containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
//        containerView.centerXAnchor.constraint(equalTo:self.contentView.centerXAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:20).isActive = true
//        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-10).isActive = true
        containerView.heightAnchor.constraint(equalToConstant:50).isActive = true
        
        //  title label auto layout constraints
        titleLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        
        //  creator label auto layout constraints
        descriptionLabel.topAnchor.constraint(equalTo:self.titleLabel.bottomAnchor, constant: 5).isActive = true
        descriptionLabel.centerXAnchor.constraint(equalTo:self.containerView.centerXAnchor).isActive = true
     }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
}
