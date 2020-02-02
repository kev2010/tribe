//
//  Privacy.swift
//  Xplore
//
//  Created by Kevin Jiang on 10/2/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit

class Privacy: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let privacy = ["Public", "Private", "Friends"]
    var toBold = [false, false, false]
    var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return privacy.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = privacy[indexPath.row]
        if toBold[indexPath.row] {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
        
        print("Section is \(section)")
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
        title.text = "Who can see your location?"
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in 0..<toBold.count{
            if i == indexPath.row {
                toBold[i] = true
            } else {
                toBold[i] = false
            }
        }
        
        currentUser?.privacy = privacy[indexPath.row]
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentUser?.privacy == "Public" {
            toBold[0] = true
        } else if currentUser?.privacy == "Private" {
            toBold[1] = true
        } else if currentUser?.privacy == "Friends" {
            toBold[2] = true
        }
        
        configureTableView()

        // Do any additional setup after loading the view.
    }
    
    func configureTableView() {
        //  Set up the settings UITable
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
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
