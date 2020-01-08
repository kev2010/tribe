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
    
    @IBOutlet var selectAddress: RoundUIView!
    
    
    @IBOutlet weak var background: RoundUIView!
    @IBOutlet weak var topUI: RoundUIView!
    @IBOutlet weak var botUI: RoundUIView!
    @IBOutlet weak var addressline: UIView!
    
    
    @IBOutlet var saveLabel: RoundUIView!
    
    @IBOutlet var capacityField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 0.6)
        let color2 = UIColor(red: 0/255, green: 182/255, blue: 255/255, alpha: 0.6)
        background.addGradientLayer(topColor: color1, bottomColor: color2)
//        addressline.addGradientLayer(topColor: color1, bottomColor: color2)
        
        topUI.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        botUI.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)


        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.academicTap))
        academicTag.addGestureRecognizer(tap)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.saveTap))
        saveLabel.addGestureRecognizer(tap3)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.artsTap))
        artsTag.addGestureRecognizer(tap2)
        
        let pickAddress = UITapGestureRecognizer(target: self, action: #selector(self.addressTap))
        selectAddress.addGestureRecognizer(pickAddress)
        
        // Do any additional setup after loading the view.
    }
    
    
    @objc func saveTap(_ sender: UITapGestureRecognizer) {
        
        self.dismiss(animated: true, completion: {})
        (self.presentingViewController as! AddEventViewController).close()
    }
    
    @objc func addressTap(_ sender: UITapGestureRecognizer) {
        
        self.performSegue(withIdentifier: "confirmLocation", sender: self)
    }
    
    
    @objc func academicTap(_ sender: UITapGestureRecognizer) {
        
        if academicTag.backgroundColor == UIColor.white {
            academicTag.backgroundColor = UIColor(red: 0, green: 182/255, blue: 1.0, alpha: 0.6)
        }
            
        else {
            academicTag.backgroundColor = UIColor.white
        }

    }
    
    @objc func artsTap(_ sender: UITapGestureRecognizer) {
        
        if artsTag.backgroundColor == UIColor.white {
            artsTag.backgroundColor = UIColor(red: 0, green: 182/255, blue: 1.0, alpha: 0.6)
        }
            
        else {
            artsTag.backgroundColor = UIColor.white
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
