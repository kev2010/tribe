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
    static func getFriends(){
        var friends : [Friend] = []
        for friend in currentUser!.friends{
            print("big yikes")
            print(friend)
            friend.getDocument { (document, error) in
                if let document = document, document.exists {
                    //  Retrieve/initialize relevant friend information
                    let uid = (document.data()!["user_information"] as! [String:Any])["uid"] as! String
                    print(uid)
                    let name = (document.data()!["user_information"] as! [String:Any])["name"] as! String
                    print(name)
                    let currentEvent = (document.data()!["user_information"] as! [String:Any])["current_event"] as! Array<Any>
                    print(currentEvent)
                    var image = UIImage()
                    var event = String()
                    
                    //  Retrieve friend's profile picture
                    let ppRef = Storage.storage().reference(withPath: "users_profilepic/\(uid)")
                    ppRef.getData(maxSize: 1 * 1024 * 1024) { data, error in    // Might need to change size?
                        if let error = error {
                            print("Error in retrieving image: \(error.localizedDescription)")
                        } else {
                            print("Got the image!")
                            image = UIImage(data: data!)!
                        }
                        
                    }
                    
                    //  Check if friend has a current event
                    if currentEvent.count == 0 {
                        print("no current event!")
                        //  Add friend struct to list with no current event
                        friends.append(Friend(picture: image, name: name, currentEvent: ""))
                        print("posted")
                        NotificationCenter.default.post(name: Notification.Name("didDownloadFriends"), object: friends)
                    } else {
                        print("has current event!")
                        //  Retrieve friend's current event
                        (currentEvent[0] as! DocumentReference).getDocument { (document, error) in
                            if let document = document, document.exists {
                                event = (document.data()!["information"] as! [String:Any])["title"] as! String
                            } else {
                                print("Event Document does not exist")
                            }
                        }
                        //  Add friend struct to list
                        friends.append(Friend(picture: image, name: name, currentEvent: event))
                        NotificationCenter.default.post(name: Notification.Name("didDownloadFriends"), object: friends)
                    }
                    
                    print("fappy")
                } else {
                    print("Friend Document does not exist")
                }
                
            }
            print("bap")

        }
        
    }
}
