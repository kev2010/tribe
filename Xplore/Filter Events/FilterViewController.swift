//
//  FilterViewController.swift
//  BoringSSL-GRPC
//
//  Created by Baptiste Bouvier on 09/08/2019.
//

import UIKit
import Firebase

class FilterViewController: UIViewController {
    
    let unselected = UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1)
    let selected = UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1)

    @IBAction func goBack(_ sender: Any) {
        let vc = self.presentingViewController as! InteractiveMap
        vc.updateFilters(new_filters: self.filterInfo)
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBOutlet weak var academic: UIButton!
    @IBOutlet weak var arts: UIButton!
    @IBOutlet weak var athletic: UIButton!
    @IBOutlet weak var casual: UIButton!
    @IBOutlet weak var professional: UIButton!
    @IBOutlet weak var social: UIButton!
    
    var filterInfo = [1, 1, 1, 1, 1, 1]

    @IBAction func filAcademic(_ sender: Any) {
        if (academic.backgroundColor != self.unselected) {
            academic.backgroundColor = self.unselected;
            filterInfo[0] = 0;
        }
        else {
            academic.backgroundColor = self.selected;
            filterInfo[0] = 1;
        }
    }
    
    @IBAction func filArts(_ sender: Any) {
        if (arts.backgroundColor != self.unselected) {
            arts.backgroundColor = self.unselected;
            filterInfo[1] = 0;
        }
        else {
            arts.backgroundColor = self.selected;
            filterInfo[1] = 1;
        }
    }
    
    @IBAction func filAthletic(_ sender: Any) {
        if (athletic.backgroundColor != self.unselected) {
            athletic.backgroundColor = self.unselected;
            filterInfo[2] = 0;
        }
        else {
            athletic.backgroundColor = self.selected;
            filterInfo[2] = 1;
        }
    }
    
    @IBAction func filCasual(_ sender: Any) {
        if (casual.backgroundColor != self.unselected) {
            casual.backgroundColor = self.unselected;
            filterInfo[3] = 0;
        }
        else {
            casual.backgroundColor = self.selected;
            filterInfo[3] = 1;
        }
    }
    
    @IBAction func filProfessional(_ sender: Any) {
        if (professional.backgroundColor != self.unselected) {
            professional.backgroundColor = self.unselected;
            filterInfo[4] = 0;
        }
        else {
            professional.backgroundColor = self.selected;
            filterInfo[4] = 1;
        }
    }
    
    @IBAction func filSocial(_ sender: Any) {
        if (social.backgroundColor != self.unselected) {
            social.backgroundColor = self.unselected;
            filterInfo[5] = 0;
        }
        else {
            social.backgroundColor = self.selected;
            filterInfo[5] = 1;
        }
    }
    
    
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

    override func viewDidLoad() {

        academic.backgroundColor = selected
        arts.backgroundColor = selected
        athletic.backgroundColor = selected
        casual.backgroundColor = selected
        professional.backgroundColor = selected
        social.backgroundColor = selected
        
        if filterInfo[0] == 0 {academic.backgroundColor = unselected}
        if filterInfo[1] == 0 {arts.backgroundColor = unselected}
        if filterInfo[2] == 0 {athletic.backgroundColor = unselected}
        if filterInfo[3] == 0 {casual.backgroundColor = unselected}
        if filterInfo[4] == 0 {professional.backgroundColor = unselected}
        if filterInfo[5] == 0 {social.backgroundColor = unselected}
        
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
        }
    }
}
