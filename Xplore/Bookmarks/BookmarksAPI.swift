//
//  BookmarksAPI.swift
//  Xplore
//
//  Created by Kevin Jiang on 10/21/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class BookmarksAPI {
    static func getBookmarks(){
        //  Initialize dispatch group to control threading & bookmarks array
        let info = DispatchGroup()
        var bookmarks : [Bookmark] = []
        
        //  Iterate through all of user's bookmarks
        for eventRef in currentUser!.eventsUserBookmarked {
            eventRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    //  Retrieve/initialize relevant event information
                    let icon = UIImage()  //  need to update picture
                    let title = (document.data()!["information"] as! [String:Any])["title"] as! String
                    let creator = document.data()!["creator_username"] as! DocumentReference
                    var username = ""
//                    let date = (document.data()!["information"] as! [String:Any])["startDate"] as! Timestamp
                    
                    //  Retrieve creator's username
                    info.enter()
                    creator.getDocument { (document, error) in
                        if let document = document, document.exists {
                            username = (document.data()!["user_information"] as! [String:Any])["username"] as! String
                        } else {
                            print("User Document does not exist")
                        }
                        info.leave()
                    }
                    
                    //  Add Bookmark struct to bookmarks list
                    info.notify(queue: DispatchQueue.main) {
                        bookmarks.append(Bookmark(picture: icon, title: title, creator: username))
                        NotificationCenter.default.post(name: Notification.Name("didDownloadBookmarks"), object: bookmarks)
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}
