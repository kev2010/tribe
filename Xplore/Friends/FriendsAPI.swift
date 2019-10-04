//
//  FriendsAPI.swift
//  Xplore
//
//  Created by Kevin Jiang on 9/7/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class FriendsAPI {
    static func getFriends() -> [Friend]{
        let friends = [Friend(name: "Baptiste Bouvier"), Friend(name: "Mohamed Mohamed"), Friend(name: "Suraj Srinivasan")]
//        let friends = [Friend(name: "Baptiste Bouvier")]

//        var friends : [Friend] = []
//        for friend in currentUser!.friends{
//            friend.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    let name = (document.data()!["user_information"] as! [String:Any])["name"] as! String
//                    let currentEvent = (document.data()!["user_information"] as! [String:Any])["current_event"] as! DocumentReference
//                    friends.append(Friend(name: name, currentEvent: currentEvent))
//
//                } else {
//                    print("Document does not exist")
//                }
//            }
//        }
        
        return friends
    }
}
