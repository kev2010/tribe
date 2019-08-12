//
//  ForgetPassword.swift
//  Xplore
//
//  Created by Kevin Jiang on 8/7/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Firebase

class ForgetPassword: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var invalidEmail: UILabel!
    @IBOutlet weak var passwordlock: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  Initially hide invalid email text
        self.invalidEmail.alpha = 0
        
        //  Add a background color gradient
        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 1)
        let color2 = UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
        //        let color2 = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        view.addGradientLayer(topColor: color1, bottomColor: color2)
        // Do any additional setup after loading the view.
        
        passwordlock.setImageColor(color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1))
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.955)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
        self.invalidEmail.alpha = 0
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendTapped(_ sender: LoginButton) {
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.955)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
        
        //  Send a password reset email
        guard let email = emailField.text else { return }
        
        if email == "" || !email.contains("@") {
            self.invalidEmail.alpha = 0.8
        } else {
            self.invalidEmail.alpha = 0
            
            Auth.auth().sendPasswordReset(withEmail: email)
            self.dismiss(animated: true, completion: nil)
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
