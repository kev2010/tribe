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

    let info = DispatchGroup()
    
    //  List of users to display on UITableView
    var friendRequests:[Friend] = []
    var filteredusers:[Friend] = []
    
    var sections = ["Pending Friend Requests"]

    //  protocol methods for addUser TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("NUMBER OF ROWS \(filteredusers.count)")
        return filteredusers.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //  Will need to adjust values later
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = .white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        header.textLabel?.text = sections[0]
        header.textLabel?.font = UIFont.init(name: "Futura-Bold", size: 18)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! AddFriendCell
        cell.isUserInteractionEnabled = true
        cell.contentView.isUserInteractionEnabled = true
        cell.friend = filteredusers[indexPath.row]
        
        
        addUser.bringSubviewToFront(cell)
        view.bringSubviewToFront(addUser)  //  Necessary?
        
        cell.leftButton.tag = indexPath.row
        cell.rightButton.tag = indexPath.row
//        if sections[0] == "Pending Friend Requests" {
            if addUserSearch.text!.count <= 2 {
            cell.leftButton.setImage(UIImage(named: "addUser"), for: .normal)
            cell.leftButton.addTarget(self, action: #selector(self.addFriend(sender:)), for: .touchUpInside)
            cell.rightButton.setImage(UIImage(named: "rejectUser"), for: .normal)
        } else {
            cell.leftButton.setImage(UIImage(), for: .normal)
            cell.rightButton.setImage(UIImage(named: "addUser"), for: .normal)
            cell.rightButton.addTarget(self, action: #selector(self.addFriend(sender:)), for: .touchUpInside)
        }
        cell.bringSubviewToFront(cell.leftButton)
        cell.bringSubviewToFront(cell.rightButton)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let currentCell = tableView.cellForRow(at: indexPath) as! AddFriendCell
//        let username = currentCell.nameLabel.text
//        addFriend(username: username!)
        addUser.reloadData()
    }
    
    @objc func addFriend(sender : UIButton) {
        if sender.currentImage == UIImage(named: "addUser") {
            sender.setImage(UIImage(named: "addedUser"), for: .normal)
            let userToUpdate = sections[0] == "Add User" ? filteredusers[sender.tag].user!.username : currentUser!.username
            let userToAdd = sections[0] == "Add User" ? currentUser!.username : filteredusers[sender.tag].user!.username
            
            let db = Firestore.firestore()
            let documentRefString = db.collection("users").document(userToAdd)
            let userRef = db.document(documentRefString.path)
            let currentDocumentRefString = db.collection("users").document(userToUpdate)
            let currentUserRef = db.document(currentDocumentRefString.path)
            let changeFriendRequest = sections[0] == "Add User" ? FieldValue.arrayUnion([userRef]) : FieldValue.arrayRemove([userRef])
            
            Firestore.firestore().collection("users").document(userToUpdate).updateData([
                "social.friend_req": changeFriendRequest
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            
            if sections[0] == "Pending Friend Requests" {
                Firestore.firestore().collection("users").document(userToUpdate).updateData([
                    "social.friends": FieldValue.arrayUnion([userRef])
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        print("Friend Added")
                        FriendsAPI.getFriends()
                    }
                }
                
                Firestore.firestore().collection("users").document(userToAdd).updateData([
                    "social.friends": FieldValue.arrayUnion([currentUserRef])
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        print("They can see you now!")
                    }
                }
            }
        }
    }
    
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        self.addUser.reloadData()
        //  Check if the text is at least 2 characters
        if searchText.count > 2 {
            sections[0] = "Add User"
            var temp: [Friend] = []
            Firestore.firestore().collection("users").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    //  Iterate through each user in users documents
                    for document in querySnapshot!.documents {
                        //  Stop displaying after 9 results
                        if self.filteredusers.count > 9 {
                            break
                        }
                        
                        //  Display the user if part of the username matches the searchText
                        let u = (document.data()["user_information"] as! [String:Any])["username"] as! String
                        let uid = (document.data()["user_information"] as! [String:Any])["uid"] as! String
                        
                        if u == currentUser?.username {
                            continue
                        }
                        
                        var currentUserFriends:[String] = []
                        for friend in (self.presentingViewController as! InteractiveMap).filteredfriends {
                            currentUserFriends.append(friend.user!.username)
                        }
                        
                        if currentUserFriends.contains(u) {
                            continue
                        }
                        
                        if u.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                            var image = UIImage()
                            
                            //  Retrieve user's profile picture
                            self.info.enter()
                            let ppRef = Storage.storage().reference(withPath: "users_profilepic/\(uid)")
                            ppRef.getData(maxSize: 1 * 1024 * 1024) { data, error in    // Might need to change size?
                                if let error = error {
                                    print("Error in retrieving image: \(error.localizedDescription)")
                                } else {
                                    image = UIImage(data: data!)!
                                }
                                self.info.leave()
                            }
                            
                            //  Add the user to the users list
                            self.info.notify(queue: DispatchQueue.main) {
                                temp.append(Friend(picture: image, user: User(DocumentSnapshot: document), currentEvent: ""))
                            }
                        }
                    }
                    
                    self.info.notify(queue: DispatchQueue.main) {
                        if self.sections[0] == "Add User" {
                            self.filteredusers = temp
                            print("TEMP SIZE \(temp.count)")
                            self.addUser.reloadData()
                        }
                    }
                }
            }
        } else {
            self.filteredusers = self.friendRequests
            self.addUser.reloadData()
            sections[0] = "Pending Friend Requests"
        }
        
        if sections[0] == "Pending Friend Requests" {
            print("ahh")
            print(filteredusers)
        } else {
            print("eek")
            print(filteredusers)
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
        filteredusers = friendRequests   // Is there a way to not do this?
        addUser.reloadData()
    }
    
    func getFriendRequests() {
        let db = Firestore.firestore()
        let documentRefString = db.collection("users").document(currentUser!.username)
        let userRef = db.document(documentRefString.path)
        var friendRequests:[DocumentReference] = []
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                friendRequests = (document.data()!["social"] as! [String:Any])["friend_req"] as! [DocumentReference]
                //  Get User Friend Requests
                for user in friendRequests{
                    self.displayUserTile(user: user)
                }
            } else {
                print("User Document does not exist")
            }
        }
    }
    
    func displayUserTile(user: DocumentReference) {
        user.getDocument { (document, error) in
            if let document = document, document.exists {
                let uid = (document.data()!["user_information"] as! [String:Any])["uid"] as! String
                var image = UIImage()
                                           
                //  Retrieve user's profile picture
                let ppRef = Storage.storage().reference(withPath: "users_profilepic/\(uid)")
                ppRef.getData(maxSize: 1 * 1024 * 1024) { data, error in    // Might need to change size?
                    if let error = error {
                       print("Error in retrieving image: \(error.localizedDescription)")
                    } else {
                        image = UIImage(data: data!)!
                        self.friendRequests.append(Friend(picture: image, user: User(DocumentSnapshot: document), currentEvent: ""))
                        self.filteredusers = self.friendRequests
                        self.addUser.reloadData()
                    }
                }
            } else {
                print("User Document does not exist")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFriendRequests()
        
        //  Set up addUser UITableView and addUserSearch UISearchBar
        print("oh", self.filteredusers)
        self.addUser.dataSource = self
        self.addUser.delegate = self
//            self.addUser.allowsSelection = false
        self.addUser.register(AddFriendCell.self, forCellReuseIdentifier: "friendCell")
        self.addUser.tableFooterView = UIView()

        self.addUserSearch.delegate = self
        self.addUserSearch.backgroundColor = .white
        self.addUserSearch.placeholder = "Search"
        self.addUserSearch.searchBarStyle = .minimal
        // SearchBar text
        let textFieldInsideUISearchBar = self.addUserSearch.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont.init(name: "Futura-Bold", size: 16)

        // SearchBar placeholder
        let textFieldInsideUISearchBarLabel = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideUISearchBarLabel?.font = UIFont.init(name: "Futura-Bold", size: 16)
        
        
    }

}
