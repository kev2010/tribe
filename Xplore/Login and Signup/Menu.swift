//
//  Menu.swift
//  Xplore
//
//  Created by Kevin Jiang on 8/3/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import FirebaseUI

class Menu: UIViewController, UITextFieldDelegate {
    
    //  Keep track of the user's email and password input
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var invalidLogin: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Initially hide error login text
        self.invalidLogin.alpha = 0
        
        //  Add a background color gradient
        view.addGradientLayer(topColor: UIColor(displayP3Red: 0/255, green: 255/255, blue: 179/255, alpha: 1), bottomColor: UIColor(displayP3Red: 0/255, green: 255/255, blue: 255/255, alpha: 1))
    }
    
    @IBAction func loginTapped(_ sender: LoginButton) {
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.955)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
        
        //  Check if both inputs are empty
        guard let email = emailField.text else { return }
        guard let pass = passwordField.text else { return }
        
        //  Attempt to sign in with Firebase
        Auth.auth().signIn(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil {
                self.performSegue(withIdentifier: "toMain", sender: self)
            } else {
                self.invalidLogin.alpha = 0.8
                print("Error logging in: \(error!.localizedDescription)")
            }
        }
    }

    
    @IBAction func signupTapped(_ sender: UIButton) {
        // Transition to sign up screen
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.955)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
        self.invalidLogin.alpha = 0
        performSegue(withIdentifier: "toSignUpScreen", sender: self)
    }
    
    
    @IBAction func forgetTapped(_ sender: UIButton) {
        // Transition to forget password screen
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.955)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
        self.invalidLogin.alpha = 0
        performSegue(withIdentifier: "toForgetPassword", sender: self)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //  Check if user is already signed in
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "toMain", sender: self)
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

extension UIView {
    
    /**
     Adds a gradient layer with two **UIColors** to the **UIView**.
     - Parameter topColor: The top **UIColor**.
     - Parameter bottomColor: The bottom **UIColor**.
     */
    
    func addGradientLayer(topColor:UIColor, bottomColor:UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            topColor.cgColor,
            bottomColor.cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

