//
//  AddFriendViewController.swift
//  Xplore
//
//  Created by Kevin Jiang on 10/21/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Firebase

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    //  IBOutlets for the UITableView and UISearchBar
    @IBOutlet weak var addUser: UITableView!
    @IBOutlet weak var addUserSearch: UISearchBar!

    //  List of users to display on UITableView
    var users:[Friend] = []

    //  protocol methods for addUser TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //  Will need to adjust values later
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! AddFriendCell
        cell.friend = users[indexPath.row]
        addUser.bringSubviewToFront(cell)
        view.bringSubviewToFront(addUser)  //  Necessary?
        return cell
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let info = DispatchGroup()
        users = []
        
        //  Check if the text is at least 2 characters
        if searchText.count > 2 {
            Firestore.firestore().collection("users").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    //  Iterate through each user in users documents
                    for document in querySnapshot!.documents {
                        //  Stop displaying after 9 results
                        if self.users.count > 9 {
                            break
                        }
                        
                        //  Display the user if part of the username matches the searchText
                        let u = (document.data()["user_information"] as! [String:Any])["username"] as! String
                        let uid = (document.data()["user_information"] as! [String:Any])["uid"] as! String
                        if u.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                            var image = UIImage()
                            
                            //  Retrieve user's profile picture
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
                            
                            //  Add the user to the users list
                            info.notify(queue: DispatchQueue.main) {
                                self.users.append(Friend(picture: image, user: User(DocumentSnapshot: document), currentEvent: ""))
                                self.addUser.reloadData()
                            }
                        }
                    }
                }
            }
        }
        self.addUser.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        addUserSearch.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        addUserSearch.showsCancelButton = false
        addUserSearch.text = ""
        addUserSearch.resignFirstResponder()
        addUserSearch.endEditing(true)
        users = []   // Is there a way to not do this?
        addUser.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //  Set up addUser UITableView and addUserSearch UISearchBar
        addUser.dataSource = self
        addUser.delegate = self
        addUser.register(AddFriendCell.self, forCellReuseIdentifier: "friendCell")
        addUser.tableFooterView = UIView()

        addUserSearch.delegate = self
        addUserSearch.backgroundColor = .white
        addUserSearch.placeholder = "Search"

    }

}
