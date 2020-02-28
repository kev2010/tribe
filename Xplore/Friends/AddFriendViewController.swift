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
            cell.leftButton.addTarget(self, action: #selector(self.acceptFriendRequest(sender:)), for: .touchUpInside)
            cell.rightButton.setImage(UIImage(named: "rejectUser"), for: .normal)
            cell.rightButton.addTarget(self, action: #selector(self.rejectFriendRequest(sender:)), for: .touchUpInside)
            cell.rightButton.imageEdgeInsets = UIEdgeInsets(top: -60, left: -60, bottom: -60, right: -60)
        } else {
            cell.leftButton.setImage(UIImage(), for: .normal)
            cell.rightButton.setImage(UIImage(named: "addUser"), for: .normal)
            cell.rightButton.addTarget(self, action: #selector(self.sendFriendRequest(sender:)), for: .touchUpInside)
            cell.rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
    
    /**
     When current user clicks the add friend button on a friend request, updates current user's and friended user's friends list with friended user and current user, respectively.
     
            @param sender the add friend UIButton
     */
    @objc func acceptFriendRequest(sender : UIButton) {
        //  Change the button UI to say "Added!"
        sender.setImage(UIImage(named: "addedUser"), for: .normal)
        //  Create document references for current user and friend request user
        let presentUser = currentUser!.username
        let incomingUser = filteredusers[sender.tag].user!.username
        
        let db = Firestore.firestore()
        let documentRefString = db.collection("users").document(incomingUser)
        let incomingUserRef = db.document(documentRefString.path)
        let currentDocumentRefString = db.collection("users").document(presentUser)
        let presentUserRef = db.document(currentDocumentRefString.path)
        
        //  Remove friend request from current user's list of friend requests in Firebase
        Firestore.firestore().collection("users").document(presentUser).updateData([
            "social.friend_req": FieldValue.arrayRemove([incomingUserRef])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        //  Add the friend to current user's list of friends in Firebase
        Firestore.firestore().collection("users").document(presentUser).updateData([
            "social.friends": FieldValue.arrayUnion([incomingUserRef])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                print("Friend Added")
                FriendsAPI.getFriends()
            }
        }
        
        //  Add current user to the new friend's list of friends in Firebase
        Firestore.firestore().collection("users").document(incomingUser).updateData([
            "social.friends": FieldValue.arrayUnion([presentUserRef])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                print("They can see you now!")
            }
        }
    }
    
    /**
    When current user sends a friend request, updates friended user's friend request list with current user
     
        @param sender the add friend UIButton
     */
    @objc func sendFriendRequest(sender : UIButton) {
        //  Change the button UI to say "Added!"
        sender.setImage(UIImage(named: "addedUser"), for: .normal)
        //  Create document references for current user and friend request user
        let presentUser = currentUser!.username
        let userToFriend = filteredusers[sender.tag].user!.username
        
        let db = Firestore.firestore()
        let documentRefString = db.collection("users").document(presentUser)
        let presentUserRef = db.document(documentRefString.path)
        
        //  Update friended user's list of friend requests
        Firestore.firestore().collection("users").document(userToFriend).updateData([
            "social.friend_req": FieldValue.arrayUnion([presentUserRef])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
    }
    
    /**
    When current user clicks the reject friend button on a friend request, removes the friend request from current user's list of a friend requests.
   
        @param sender the add friend UIButton
    */
    @objc func rejectFriendRequest(sender : UIButton) {
        //  Create document references for current user and rejected user
        let presentUser = currentUser!.username
        let rejectedUser = filteredusers[sender.tag].user!.username
        
        let db = Firestore.firestore()
        let rejectedUserDocumentRefString = db.collection("users").document(rejectedUser)
        let rejectedUserRef = db.document(rejectedUserDocumentRefString.path)
        
        //  Remove rejected user from current user's friend request list
        Firestore.firestore().collection("users").document(presentUser).updateData([
            "social.friend_req": FieldValue.arrayRemove([rejectedUserRef])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
                        
                        //  Don't display the current user
                        if u == currentUser?.username {
                            continue
                        }
                        
                        //  Don't display any of the user's friend(s)
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
                            self.addUser.reloadData()
                        }
                    }
                }
            }
        } else {
            //  If not searching for a user, then list out friend requests
            self.filteredusers = self.friendRequests
            self.addUser.reloadData()
            sections[0] = "Pending Friend Requests"
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
