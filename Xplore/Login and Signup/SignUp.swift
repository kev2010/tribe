//
//  SignUp.swift
//  Xplore
//
//  Created by Kevin Jiang on 8/3/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Foundation
import Mapbox
import Firebase

class SignUp: UIViewController, UITextFieldDelegate {
    
    //  Outlets for each of the user's inputs into register screen
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //  Set up Firestore Database
    private var datePicker: UIDatePicker!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Add Background gradient
        view.addGradientLayer(topColor: UIColor(displayP3Red: 0/255, green: 255/255, blue: 179/255, alpha: 1), bottomColor: UIColor(displayP3Red: 0/255, green: 255/255, blue: 255/255, alpha: 1))
        
        //  Set up date input
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(SignUp.dateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUp.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        dobField.inputView = datePicker
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyy"
        dobField.text = dateFormatter.string(for: datePicker.date)
        view.endEditing(true)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerTapped(_ sender: LoginButton) {
        //  Make sure all fields aren't empty
        guard let name = nameField.text else { return }
        guard let dob = dobField.text else { return }
        guard let email = emailField.text else { return }
        guard let username = usernameField.text else { return }
        guard let pass = passwordField.text else { return }
        
        //  Create user on Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil {
                print("User created!")
                
                //  Update displayName onto Firebase Authentication (is this necessary?)
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        self.dismiss(animated: false, completion: nil)
                    } else {
                        print("Error: \(error!.localizedDescription)")
                    }
                }
                
                //  Store new user and default information into UID document
                let uid = String(Auth.auth().currentUser!.uid)
                let userinfo = ["status": "green", "current_event": "", "dob": dob, "email": email, "location": nil, "name": name, "private": false, "rating": 5, "username": username] as [String : Any?]
                let socialinfo = ["friends": [], "blocked": []] as [String : Any?]
                let eventsinfo = ["attended": [], "bookmarked": [], "hosted": [], "interested": [], "tags": [:]] as [String : Any]
                
                self.db.collection("users").document(uid).setData(["user_information": userinfo, "social": socialinfo, "events": eventsinfo])
                
            } else {
                print("Error: \(error!.localizedDescription)")
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
