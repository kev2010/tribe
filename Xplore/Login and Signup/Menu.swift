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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Add a background color gradient
        view.addGradientLayer(topColor: UIColor(displayP3Red: 51/255, green: 51/255, blue: 153/255, alpha: 1), bottomColor: UIColor(displayP3Red: 98/255, green: 119/255, blue: 223/255, alpha: 1))
        
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    @IBAction func loginTapped(_ sender: LoginButton) {
        //  Check if both inputs are empty
        guard let email = emailField.text else { return }
        guard let pass = passwordField.text else { return }
        
        //  Attempt to sign in with Firebase
        Auth.auth().signIn(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil {
                self.performSegue(withIdentifier: "toMain", sender: self)
            } else {
                print("Error logging in: \(error!.localizedDescription)")
            }
        }
    }

    @IBAction func signupTapped(_ sender: UIButton) {
        // Transition to sign up screen
        performSegue(withIdentifier: "toSignUpScreen", sender: self)
    }
    
    
//    @IBAction func loginTap(_ sender: UIButton) {
//        performSegue(withIdentifier: "toLoginScreen", sender: self)
//        let authUI = FUIAuth.defaultAuthUI()
//
//        guard authUI != nil else {
//            return
//        }
//
//        authUI?.delegate = self
//        authUI?.providers = [FUIEmailAuth()]
//
//        let authViewController = authUI!.authViewController()
//
//        present(authViewController, animated: true, completion: nil)
//    }
    

    
    
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

extension Menu: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            return
        }
        
        // do stuff with uid in the future
        
        performSegue(withIdentifier: "toHome", sender: self)
    }
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

