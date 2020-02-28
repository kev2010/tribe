//
//  SearchViewController.swift
//  Xplore
//
//  Created by Kevin Jiang on 11/23/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Firebase
import Mapbox

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var searchEvent: UISearchBar!
    @IBOutlet weak var noEventsText: UILabel!
    
    let info = DispatchGroup()
    var filterInfo = [1, 1, 1, 1, 1, 1]
    
    struct Section {
        var name: String
        var tag: Int
        var items: [Search]
        var collapsed: Bool
        
        init(name: String, tag: Int, items: [Search], collapsed: Bool = false) {
        self.name = name
        self.tag = tag
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //  Will need to adjust values later
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        let item = filteredsections[indexPath.section].items[indexPath.row]
        cell.event = item // ???


        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.presentingViewController as! InteractiveMap
        
        let item = filteredsections[indexPath.section].items[indexPath.row]
        let a = vc.annotationsForID[item.event!.documentID!]!
        vc.mapView.selectAnnotation(a, animated: true) {
            let botleft = CLLocationCoordinate2D(latitude: a.coordinate.latitude - 0.01, longitude: a.coordinate.longitude - 0.01)
            let topright = CLLocationCoordinate2D(latitude: a.coordinate.latitude + 0.01, longitude: a.coordinate.longitude + 0.01)
            let region:MGLCoordinateBounds = MGLCoordinateBounds(sw: botleft, ne: topright)
            
            vc.mapView.setVisibleCoordinateBounds(region, animated: false)
        }
        self.dismiss(animated: true)
        
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
            var temp:[Section] = []
            for sec in sections {
                var items = [Search]()
                for search in sec.items {
                    print(search)
                    if search.event?.title.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                        items.append(search)
                    }
                }
                if items.count > 0 {
                    var temp_list: [Search] = []
                    temp_list = items.sorted(by: { $0.event!.startDate < $1.event!.startDate })
                    temp.append(Section(name: sec.name, tag: sec.tag, items: temp_list))
                }
            }
            filteredsections = temp.sorted(by: { $0.tag < $1.tag })
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
        self.info.enter()
        Firestore.firestore().collection("events").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                //  Iterate through each event in events documents
                for document in querySnapshot!.documents {
                    let event = Event(QueryDocumentSnapshot: document)
                    
                    let filtered = event.tags.contains("Academic") && self.filterInfo[0]==1 ||
                        event.tags.contains("Arts") && self.filterInfo[1]==1 ||
                        event.tags.contains("Athletic") && self.filterInfo[2]==1 ||
                        event.tags.contains("Casual") && self.filterInfo[3]==1 ||
                        event.tags.contains("Professional") && self.filterInfo[4]==1 ||
                        event.tags.contains("Social") && self.filterInfo[5]==1;
                    
                    if (filtered) {
                        self.noEventsText.isHidden = true;
                        let start = event.startDate

                        let dateFormatter = DateFormatter()
                        // uncomment to enforce the US locale
                        // dateFormatter.locale = Locale(identifier: "en-US")
                        dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMM d yyyy")
                        let time = dateFormatter.string(from: start)

                        if date_dic[time] != nil {
                            date_dic[time]?.append(Search(event: event))
                        } else {
                            date_dic[time] = [Search(event: event)]
                        }
                    }

                }
                self.info.leave()
            }
        }

//
//                //  Iterate through each event in events documents
//        let vc = self.presentingViewController as! InteractiveMap
//            for events in vc.allEventsSearch {
//                for event in events {
//                    let start = event.startDate
//
//                    let dateFormatter = DateFormatter()
//                    // uncomment to enforce the US locale
//                    // dateFormatter.locale = Locale(identifier: "en-US")
//                    dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMM d yyyy")
//                    let time = dateFormatter.string(from: start)
//
//                    if date_dic[time] != nil {
//                        date_dic[time]?.append(Search(event: event, annotation: ))
//                    } else {
//                        date_dic[time] = [Search(event: event)]
//                    }
//
//                }
//            }
//
        self.info.notify(queue: DispatchQueue.main) {
            var temp: [Section] = []
            for (date, list) in date_dic {
                var year: Int
                var day: Int
                
                if date[10] == "," {
                    year = Int(date.substring(fromIndex: 12))!
                    day = Int(date[9])!
                } else {
                    year = Int(date.substring(fromIndex: 13))!
                    day = Int(date[9 ..< 11])!
                }
                let month = self.monthToNum(month: date[5 ..< 8])
                let tag = year * 10000 + month * 100 + day
                
                var temp_list: [Search] = []
                temp_list = list.sorted(by: { $0.event!.startDate < $1.event!.startDate })
                    
                temp.append(Section(name: date, tag: tag, items: temp_list))
            }
            self.sections = temp.sorted(by: { $0.tag < $1.tag })
            self.filteredsections = self.sections
            //self.filteredsections = []
            
            //  Set up addUser UITableView and addUserSearch UISearchBar
            self.searchTable.dataSource = self
            self.searchTable.delegate = self
    //            self.addUser.allowsSelection = false
            self.searchTable.register(SearchCell.self, forCellReuseIdentifier: "searchCell")
            self.searchTable.tableFooterView = UIView()
            // Auto resizing the height of the cell
            self.searchTable.estimatedRowHeight = 44.0
            self.searchTable.rowHeight = UITableView.automaticDimension

            self.searchEvent.delegate = self
            self.searchEvent.backgroundColor = .white
            self.searchEvent.placeholder = "Search"
            self.searchEvent.searchBarStyle = .minimal
            // SearchBar text
            let textFieldInsideUISearchBar = self.searchEvent.value(forKey: "searchField") as? UITextField
            textFieldInsideUISearchBar?.font = UIFont.init(name: "Futura-Bold", size: 16)

            // SearchBar placeholder
            let textFieldInsideUISearchBarLabel = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
            textFieldInsideUISearchBarLabel?.font = UIFont.init(name: "Futura-Bold", size: 16)
            
        }
    }
    
    func monthToNum(month:String) -> Int{
        
        switch month {
            case "Jan":
                return 1
            case "Feb":
                return 2
            case "Mar":
                return 3
            case "Apr":
                return 4
            case "May":
                return 5
            case "Jun":
                return 6
            case "Jul":
                return 7
            case "Aug":
                return 8
            case "Sep":
                return 9
            case "Oct":
                return 10
            case "Nov":
                return 11
            case "Dec":
                return 12
            default:
                print("ERROR, unknown key")
                assert(false)
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

extension String {
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
