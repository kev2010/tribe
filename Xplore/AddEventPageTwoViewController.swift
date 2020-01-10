//
//  AddEventPageTwoViewController.swift
//  Xplore
//
//  Created by Baptiste Bouvier on 26/11/2019.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit

class AddEventPageTwoViewController: UIViewController {

    @IBOutlet var academicTag: RoundUIView!
    @IBOutlet var artsTag: RoundUIView!
    @IBOutlet var professionalTag: RoundUIView!
    @IBOutlet var athleticTag: RoundUIView!
    @IBOutlet var socialTag: RoundUIView!
    @IBOutlet var casualTag: RoundUIView!
    
    
    @IBOutlet weak var academicLabel: UILabel!
    @IBOutlet weak var artsLabel: UILabel!
    @IBOutlet weak var athleticLabel: UILabel!
    @IBOutlet weak var casualLabel: UILabel!
    @IBOutlet weak var professionalLabel: UILabel!
    @IBOutlet weak var socialLabel: UILabel!
    
    
//    @IBOutlet var selectAddress: RoundUIView!
    
    
    @IBOutlet weak var background: RoundUIView!
    @IBOutlet weak var topUI: RoundUIView!
//    @IBOutlet weak var botUI: RoundUIView!
//    @IBOutlet weak var addressline: UIView!
    
    
//    @IBOutlet var saveLabel: RoundUIView!
    
    @IBOutlet var capacityField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 0.6)
//        let color2 = UIColor(red: 0/255, green: 182/255, blue: 255/255, alpha: 0.6)
//        background.addGradientLayer(topColor: color1, bottomColor: color2)
//        addressline.addGradientLayer(topColor: color1, bottomColor: color2)
        
//        topUI.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
//        botUI.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)


        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.academicTap))
        academicTag.addGestureRecognizer(tap)
        
//        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.saveTap))
//        saveLabel.addGestureRecognizer(tap3)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.artsTap))
        artsTag.addGestureRecognizer(tap2)
        
//        let pickAddress = UITapGestureRecognizer(target: self, action: #selector(self.addressTap))
//        selectAddress.addGestureRecognizer(pickAddress)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backTap(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func saveTap(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.955)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
        
        self.dismiss(animated: true, completion: {})
        (self.presentingViewController as! AddEventViewController).close()
    }
    
    
    @objc func addressTap(_ sender: UITapGestureRecognizer) {
        
        self.performSegue(withIdentifier: "confirmLocation", sender: self)
    }
    
    
    @objc func academicTap(_ sender: UITapGestureRecognizer) {
        
        // Note the first click doens't do anything for some reason? the clicks afterwards work perfectly
        if academicTag.backgroundColor == UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1) {
            academicTag.backgroundColor = UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1)
            academicLabel.textColor = .white
        }
            
        else {
            academicTag.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1)
            academicLabel.textColor = .lightGray
        }

    }
    
    @objc func artsTap(_ sender: UITapGestureRecognizer) {
        
        // Note the first click doens't do anything for some reason? the clicks afterwards work perfectly
        if artsTag.backgroundColor == UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1) {
            artsTag.backgroundColor = UIColor(red: 49/255, green: 1.0, blue: 189/255, alpha: 1)
            artsLabel.textColor = .white
        }
            
        else {
            artsTag.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1)
            artsLabel.textColor = .lightGray
        }

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
