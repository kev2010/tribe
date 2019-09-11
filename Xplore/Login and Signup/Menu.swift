//
//  Menu.swift
//  Xplore
//
//  Created by Kevin Jiang on 8/3/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase


class Menu: UIViewController, UITextFieldDelegate {
    
    //  Keep track of the user's email and password input
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var invalidLogin: UILabel!
    
    let db = Firestore.firestore()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //  Initially hide error login text
        self.invalidLogin.alpha = 0
        
        //  Add a background color gradient
//        let color1 = UIColor(red: 83/255, green: 134/255, blue: 228/255, alpha: 1)
//        let color2 = UIColor(red: 58/255, green: 68/255, blue: 84/255, alpha: 1)
//        let color2 = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
//        let color2 = UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1)
//        let color1 = UIColor(red: 0/255, green: 255/255, blue: 179/255, alpha: 1)
        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 1)
        let color2 = UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
//
//        view.addGradientLayer(topColor: color1, bottomColor: color2)
        view.addGradientLayer(topColor: color1, bottomColor: color2)
        
        // UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
        
        //  Adding keyboard functionality
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            self.passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            self.passwordField.resignFirstResponder()
        }
        return true
    }
    
    //  Repeated multiple times in the code, there should be a better way to structure this
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
                
                let username = user!.user.displayName!
                let docRef = self.db.collection("users").document(username)
                
                print("test")
                docRef.getDocument { (document, error) in
                    if let d = document {
                        
                        currentUser = User(DocumentSnapshot: d)
                        self.performSegue(withIdentifier: "toMain", sender: self)
                    } else {
                    
                    self.invalidLogin.alpha = 0.8
                    print("Error logging in")
                    assert(1==2)
                    }
                }
                
                
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
        if Auth.auth().currentUser != nil{
            let user = Auth.auth().currentUser!
            if user.displayName == nil {
                return
            }
            let username = user.displayName!
            let docRef = self.db.collection("users").document(username)
            
            docRef.getDocument { (document, error) in
                if let d = document {
                    currentUser = User(DocumentSnapshot: d)
                    self.performSegue(withIdentifier: "toMain", sender: self)
                    
                }
            
        }
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
    
    func addGradientLayer(topColor:UIColor, bottomColor:UIColor, start:CGPoint = CGPoint(x: 1, y: 0), end:CGPoint = CGPoint(x: 0, y: 1)) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            topColor.cgColor,
            bottomColor.cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = start
        gradient.endPoint = end
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    
}

