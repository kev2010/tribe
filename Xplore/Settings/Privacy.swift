//
//  Privacy.swift
//  Xplore
//
//  Created by Kevin Jiang on 10/2/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit

class Privacy: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let privacy = ["Public", "Friends", "Friends Except for...", "Only These Friends..."]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return privacy.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = privacy[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
