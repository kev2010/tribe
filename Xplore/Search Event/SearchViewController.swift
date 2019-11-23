//
//  SearchViewController.swift
//  Xplore
//
//  Created by Kevin Jiang on 11/23/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var searchEvent: UISearchBar!
    
    let info = DispatchGroup()
    
    //  List of users to display on UITableView
    var events:[Search] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //  Will need to adjust values later
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        cell.event = events[indexPath.row] // ???


        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        events = []
        
        //  Check if the text is at least 3 characters
        if searchText.count >= 3 {
            Firestore.firestore().collection("events").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    //  Iterate through each event in events documents
                    for document in querySnapshot!.documents {
//                        //  Stop displaying after 9 results
//                        if self.events.count > 9 {
//                            break
//                        }
                        
                        //  Display the user if part of the username matches the searchText
                        let u = (document.data()["information"] as! [String:Any])["title"] as! String
//                        let uid = (document.data()["information"] as! [String:Any])["uid"] as! String
                        if u.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
//                            var image = UIImage()
                            
//                            //  Retrieve user's profile picture
//                            self.info.enter()
//                            let ppRef = Storage.storage().reference(withPath: "users_profilepic/\(uid)")
//                            ppRef.getData(maxSize: 1 * 1024 * 1024) { data, error in    // Might need to change size?
//                                if let error = error {
//                                    print("Error in retrieving image: \(error.localizedDescription)")
//                                } else {
//                                    image = UIImage(data: data!)!
//                                }
//                                self.info.leave()
//                            }
                            
                            //  Add the user to the users list
                            self.info.notify(queue: DispatchQueue.main) {
                                self.events.append(Search(event: Event(QueryDocumentSpapshot: document)))
                                self.searchTable.reloadData()
                            }
                        }
                    }
                }
            }
        }
        self.searchTable.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchEvent.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchEvent.showsCancelButton = false
        searchEvent.text = ""
        searchEvent.resignFirstResponder()
        searchEvent.endEditing(true)
        events = []   // Is there a way to not do this?
        searchTable.reloadData()
    }

    override func viewDidLoad() {
        //  Set up addUser UITableView and addUserSearch UISearchBar
        self.searchTable.dataSource = self
        self.searchTable.delegate = self
//            self.addUser.allowsSelection = false
        self.searchTable.register(SearchCell.self, forCellReuseIdentifier: "searchCell")
        self.searchTable.tableFooterView = UIView()

        self.searchEvent.delegate = self
        self.searchEvent.backgroundColor = .white
        self.searchEvent.placeholder = "Search"
    }

}
