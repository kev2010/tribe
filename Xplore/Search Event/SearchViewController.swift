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
    
    struct Section {
      var name: String
      var items: [Search]
      var collapsed: Bool
        
      init(name: String, items: [Search], collapsed: Bool = false) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
      }
    }
    
    var filteredsections = [Section]()
    var sections = [Section]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredsections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredsections[section].collapsed ? 0 : filteredsections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SearchTableViewHeader ?? SearchTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = filteredsections[section].name
        header.arrowLabel.text = ">"
        header.setCollapsed(filteredsections[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 1.0
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //  Will need to adjust values later
        return 75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        let item = filteredsections[indexPath.section].items[indexPath.row]
        cell.event = item // ???


        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = filteredsections[indexPath.section].items[indexPath.row]
//        self.goMap()
//        guard let location = cell.event?.location else { return }
//        guard let title = cell.event?.title else { return }
//        guard let capacity = cell.event?.capacity else { return }
//        guard let description = cell.event?.description else { return }
//
//        let point = CustomPointAnnotation(coordinate: location, title: title, subtitle: "\(capacity) people", description: description)
////            mapView(self.mapView, imageFor: point)
////            mapView(self.mapView, didSelect: point)
//        self.mapView.selectAnnotation(point, animated: true) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //  Check if the text is at least 2 characters
        if searchText.count >= 2 {
            // Rebuild the sections table - creation strategy, would deletion strategy be better?
            filteredsections = []
            for sec in sections {
                var items = [Search]()
                for search in sec.items {
                    if search.event?.title.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                        items.append(search)
                    }
                }
                if items.count > 0 {
                    filteredsections.append(Section(name: sec.name, items: items))
                }
            }
        } else {
            filteredsections = sections
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
        filteredsections = sections   // Is there a way to not do this?
        searchTable.reloadData()
    }

    override func viewDidLoad() {
        
        var date_dic: [String: [Search]] = [:] as! [String : [Search]]
        //  Grab all events
        self.info.enter()
        Firestore.firestore().collection("events").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                //  Iterate through each event in events documents
                for document in querySnapshot!.documents {
                    let event = Event(QueryDocumentSnapshot: document)
                    let start = event.startDate
                    
                    let dateFormatter = DateFormatter()
                    // uncomment to enforce the US locale
                    // dateFormatter.locale = Locale(identifier: "en-US")
                    dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMM d yyyy")
                    
                    
//                    let calendar = Calendar.current
//
//                    let weekday = String(calendar.component(.weekday, from: start))
//                    let month = String(calendar.component(.month, from: start))
//                    let day = String(calendar.component(.day, from: start))
//                    let year = String(calendar.component(.year, from: start))
                    let time = dateFormatter.string(from: start)
                    
                    if date_dic[time] != nil {
                        date_dic[time]?.append(Search(event: event))
                    } else {
                        date_dic[time] = [Search(event: event)]
                    }
                    
//                    let u = (document.data()["information"] as! [String:Any])["title"] as! String
//                    self.info.notify(queue: DispatchQueue.main) {
//                        self.events.append(Search(event: Event(QueryDocumentSpapshot: document)))
//                        self.searchTable.reloadData()
//                    }
                }
                self.info.leave()
            }
        }
        
        self.info.notify(queue: DispatchQueue.main) {
            for (date, list) in date_dic {
                self.sections.append(Section(name: date, items: list))
            }
            self.filteredsections = self.sections
            
            //  Set up addUser UITableView and addUserSearch UISearchBar
            self.searchTable.dataSource = self
            self.searchTable.delegate = self
    //            self.addUser.allowsSelection = false
            self.searchTable.register(SearchCell.self, forCellReuseIdentifier: "searchCell")
            self.searchTable.tableFooterView = UIView()
            // Auto resizing the height of the cell
//            self.searchTable.estimatedRowHeight = 44.0
//            self.searchTable.rowHeight = UITableView.automaticDimension

            self.searchEvent.delegate = self
            self.searchEvent.backgroundColor = .white
            self.searchEvent.placeholder = "Search"
        }
    }

}

extension SearchViewController: SearchTableViewHeaderDelegate {
    
    func toggleSection(_ header: SearchTableViewHeader, section: Int) {
        let collapsed = !filteredsections[section].collapsed
        
        // Toggle collapse
        filteredsections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        self.searchTable.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
}
