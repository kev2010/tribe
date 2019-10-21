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
        //  Initialize dispatch group to control threading & friends array
        let info = DispatchGroup()
        var friends : [Friend] = []
        
        //  Iterate through all of user's friends
        for friend in currentUser!.friends{
            friend.getDocument { (document, error) in
                if let document = document, document.exists {
                    //  Retrieve/initialize relevant friend information
                    let uid = (document.data()!["user_information"] as! [String:Any])["uid"] as! String
                    let name = (document.data()!["user_information"] as! [String:Any])["name"] as! String
                    let currentEvent = (document.data()!["user_information"] as! [String:Any])["current_event"] as! Array<Any>
                    var image = UIImage()
                    var event = String()
                    
                    //  Retrieve friend's profile picture
                    info.enter()
                    let ppRef = Storage.storage().reference(withPath: "users_profilepic/\(uid)")
                    ppRef.getData(maxSize: 1 * 1024 * 1024) { data, error in    // Might need to change size?
                        if let error = error {
                            print("Error in retrieving image: \(error.localizedDescription)")
                        } else {
                            image = UIImage(data: data!)!
                        }
                        info.leave()
                    }
                    
                    //  Check if friend has a current event after retrieving picture
                    info.notify(queue: DispatchQueue.main) {
                        if currentEvent.count == 0 {
                            //  Add friend struct to list with no current event
                            friends.append(Friend(picture: image, name: name, currentEvent: ""))
                            NotificationCenter.default.post(name: Notification.Name("didDownloadFriends"), object: friends)
                        } else {
                            //  Retrieve friend's current event
                            info.enter()
                            (currentEvent[0] as! DocumentReference).getDocument { (document, error) in
                                if let document = document, document.exists {
                                    event = (document.data()!["information"] as! [String:Any])["title"] as! String
                                } else {
                                    print("Event Document does not exist")
                                }
                                info.leave()
                            }
                            //  Add friend struct to list
                            info.notify(queue: DispatchQueue.main) {
                                friends.append(Friend(picture: image, name: name, currentEvent: event))
                                NotificationCenter.default.post(name: Notification.Name("didDownloadFriends"), object: friends)
                            }
                        }
                    }
                } else {
                    print("Friend Document does not exist")
                }
                
            }
            print("bap")

        }
        
    }
}
