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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Do any additional setup after loading the view.
    }
    
    func configureTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        tableView.tableFooterView = UIView()
    }
    
    func configureUI() {
        
        configureTableView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default
        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 1)
        let color2 = UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = color1
        navigationItem.title = "Settings"
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
        view.backgroundColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        
        print("Section is \(section)")
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
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

        switch section {
        case .Social:
            let social = SocialOptions(rawValue: indexPath.row)
            cell.sectionType = social
        case .Communications:
            let communications = CommunicationOptions(rawValue: indexPath.row)
            cell.sectionType = communications
        }
        
        return cell
    }
    
    //  Remove string descriptions of settings cells?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }

        switch section {
        case .Social:
            let description = SocialOptions(rawValue: indexPath.row)?.description
            print(description)
            if description == "Log Out" {
                try! Auth.auth().signOut()
//                self.performSegue(withIdentifier: "unwindToLogin", sender: self)
                //  DEBUG: Attempting to go back to root view controller (login page)
                _ = self.navigationController?.popToRootViewController(animated: true)
                
            }
                
        case .Communications:
            let description = CommunicationOptions(rawValue: indexPath.row)?.description
            print(description)
            if description == "Back" {
                //  DEBUG: Attempting to go back to home page
                DispatchQueue.main.async {
                    print("Waht's going on???")
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    
}
