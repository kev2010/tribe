//
//  SettingsViewController.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 09/08/2019.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SettingsCell"

class SettingsViewController: UIViewController {
    
    //  MARK: - Properties
    var tableView: UITableView!
//    var window: UIWindow?
    @IBOutlet weak var settingsHeader: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        //  Update Firebase user data upon exiting settings screen
        currentUser?.updateUser()
    }
    
    func configureTableView() {
        //  Set up the settings UITable
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: 88, width: view.frame.width, height: view.frame.height)
        
        tableView.tableFooterView = UIView()
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        
        switch section {
        case .Social: return SocialOptions.allCases.count
        case .Communications: return CommunicationOptions.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 255/255, blue: 194/255, alpha: 1)
        
        print("Section is \(section)")
        
        let title = UILabel()
        title.font = UIFont(name: "Futura-Bold", size: 16)
        title.textColor = .white
        title.text = SettingsSection(rawValue: section)?.description
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        cell.textLabel?.font = UIFont(name: "Futura-Bold", size: 16)
        cell.textLabel?.alpha = 0.5
        
        switch section {
        case .Social:
            let social = SocialOptions(rawValue: indexPath.row)
            cell.sectionType = social
            
            if social?.description == "Log Out" {
                cell.textLabel?.textColor = .red
                cell.textLabel?.alpha = 0.7
            }
            
        case .Communications:
            let communications = CommunicationOptions(rawValue: indexPath.row)
            cell.sectionType = communications
        }
        
        return cell
    }
    
    //  Remove string descriptions of settings cells?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        switch section {
        case .Social:
            let description = SocialOptions(rawValue: indexPath.row)?.description
            
            if description == "Privacy" {
                self.performSegue(withIdentifier: "toPrivacy", sender: self)
            }
            
            if description == "Log Out" {
                currentUser?.updateUser()
                try! Auth.auth().signOut()
                self.performSegue(withIdentifier: "logout", sender: self)
            }
                
        case .Communications:
            let description = CommunicationOptions(rawValue: indexPath.row)?.description
            
            if description == "Terms of Service" {
                self.performSegue(withIdentifier: "toToS", sender: self)
            }
            
            if description == "Contact Us!" {
                if let url = URL(string: "https://www.tribe-app.com") {
                    UIApplication.shared.open(url)
                }
            }
        }
        
    }
    
    
}
