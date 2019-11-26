//
//  FilterViewController.swift
//  BoringSSL-GRPC
//
//  Created by Baptiste Bouvier on 09/08/2019.
//

import UIKit
import Firebase

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UISearchBarDelegate {

    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func filAcademic(_ sender: Any) {
    }
    
    @IBAction func filArts(_ sender: Any) {
    }
    
    @IBAction func filAthletics(_ sender: Any) {
    }
    
    @IBAction func filProfessional(_ sender: Any) {
    }
    
    @IBAction func filSocial(_ sender: Any) {
    }
    
    @IBAction func filCasual(_ sender: Any) {
    }
    @IBOutlet weak var filterTable: UITableView!
    
    let info = DispatchGroup()
    
    //  List of users to display on UITableView
    var events:[Filter] = []
    
    struct Section {
      var name: String
      var items: [Filter]
      var collapsed: Bool
        
      init(name: String, items: [Filter], collapsed: Bool = false) {
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
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? FilterTable ?? FilterTable(reuseIdentifier: "header")
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //  Will need to adjust values later
        return 75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! FilterCellTableViewCell
        let item = filteredsections[indexPath.section].items[indexPath.row]
        cell.event = item // ???


        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //  Check if the text is at least 2 characters
        if searchText.count >= 2 {
            // Rebuild the sections table - creation strategy, would deletion strategy be better?
            filteredsections = []
            for sec in sections {
                var items = [Filter]()
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
        
        self.filterTable.reloadData()
    }

    override func viewDidLoad() {
        
        var date_dic: [String: [Filter]] = [:] as! [String : [Filter]]
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
                    
                    let time = dateFormatter.string(from: start)
                    
                    if date_dic[time] != nil {
                        date_dic[time]?.append(Filter(event: event))
                    } else {
                        date_dic[time] = [Filter(event: event)]
                    }
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
            self.filterTable.dataSource = self
            self.filterTable.delegate = self
            self.filterTable.register(FilterCellTableViewCell.self, forCellReuseIdentifier: "filterCell")
            self.filterTable.tableFooterView = UIView()
        }
    }
}

extension FilterViewController: FilterTableDelegate {
    
    func toggleSection(_ header: FilterTable, section: Int) {
        let collapsed = !filteredsections[section].collapsed
        
        // Toggle collapse
        filteredsections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        self.filterTable.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
}
