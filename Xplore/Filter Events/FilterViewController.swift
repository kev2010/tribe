//
//  FilterViewController.swift
//  BoringSSL-GRPC
//
//  Created by Baptiste Bouvier on 09/08/2019.
//

import UIKit
import Firebase

class FilterViewController: UIViewController {

    @IBAction func goBack(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "filterData", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! InteractiveMap;
        vc.filterApp = self.filterInfo;
    }
    
    @IBOutlet weak var academic: UIButton!
    @IBOutlet weak var arts: UIButton!
    @IBOutlet weak var athletic: UIButton!
    @IBOutlet weak var casual: UIButton!
    @IBOutlet weak var professional: UIButton!
    @IBOutlet weak var social: UIButton!
    
    var filterInfo = [1, 1, 1, 1, 1, 1]

    @IBAction func filAcademic(_ sender: Any) {
        if (academic.backgroundColor != UIColor.gray) {
            academic.backgroundColor = UIColor.gray;
            filterInfo[0] = 0;
        }
        else {
            academic.backgroundColor = UIColor.systemBlue;
            filterInfo[0] = 1;
        }
    }
    
    @IBAction func filArts(_ sender: Any) {
        if (arts.backgroundColor != UIColor.gray) {
            arts.backgroundColor = UIColor.gray;
            filterInfo[1] = 0;
        }
        else {
            arts.backgroundColor = UIColor.systemBlue;
            filterInfo[1] = 1;
        }
    }
    
    @IBAction func filAthletic(_ sender: Any) {
        if (athletic.backgroundColor != UIColor.gray) {
            athletic.backgroundColor = UIColor.gray;
            filterInfo[2] = 0;
        }
        else {
            athletic.backgroundColor = UIColor.systemBlue;
            filterInfo[2] = 1;
        }
    }
    
    @IBAction func filCasual(_ sender: Any) {
        if (casual.backgroundColor != UIColor.gray) {
            casual.backgroundColor = UIColor.gray;
            filterInfo[3] = 0;
        }
        else {
            casual.backgroundColor = UIColor.systemBlue;
            filterInfo[3] = 1;
        }
    }
    
    @IBAction func filProfessional(_ sender: Any) {
        if (professional.backgroundColor != UIColor.gray) {
            professional.backgroundColor = UIColor.gray;
            filterInfo[4] = 0;
        }
        else {
            professional.backgroundColor = UIColor.systemBlue;
            filterInfo[4] = 1;
        }
    }
    
    @IBAction func filSocial(_ sender: Any) {
        if (social.backgroundColor != UIColor.gray) {
            social.backgroundColor = UIColor.gray;
            filterInfo[5] = 0;
        }
        else {
            social.backgroundColor = UIColor.systemBlue;
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
