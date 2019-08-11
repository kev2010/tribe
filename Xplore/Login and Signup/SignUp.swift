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
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var missingFields: UILabel!
    @IBOutlet weak var emailTaken: UILabel!
    @IBOutlet weak var usernameInvalid: UILabel!
    @IBOutlet weak var usernameShort: UILabel!
    @IBOutlet weak var usernameTaken: UILabel!
    @IBOutlet weak var shortPassword: UILabel!
    
    //  Set up Firestore Database
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  Initially hide missingFields and shortPassword error
        self.missingFields.alpha = 0
        self.emailTaken.alpha = 0
        self.usernameInvalid.alpha = 0
        self.usernameShort.alpha = 0
        self.usernameTaken.alpha = 0
        self.shortPassword.alpha = 0
        
        //  Add Background gradient
        view.addGradientLayer(topColor: UIColor(displayP3Red: 0/255, green: 255/255, blue: 179/255, alpha: 1), bottomColor: UIColor(displayP3Red: 0/255, green: 255/255, blue: 255/255, alpha: 1))
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
        
        self.missingFields.alpha = 0
        self.emailTaken.alpha = 0
        self.usernameInvalid.alpha = 0
        self.usernameShort.alpha = 0
        self.usernameTaken.alpha = 0
        self.shortPassword.alpha = 0
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func registerTapped(_ sender: LoginButton) {
        //  Add button animation
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.955)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
        
        //  Make sure all fields aren't nil
        guard let name = nameField.text else { return }
        guard let email = emailField.text else { return }
        guard let username = usernameField.text else { return }
        guard let pass = passwordField.text else { return }
        
        //  Make sure all field requirements are fulfilled
        var valid = true
        
        //  Check if any field is empty and email has "@"
        if name == "" || email == "" || username == "" || !email.contains("@") {
            self.missingFields.alpha = 0.8
            valid = false
        } else {
            self.missingFields.alpha = 0
        }
        
        //  Check if username has valid syntax and doesn't already exist
        if username.count < 3 {
            self.usernameShort.alpha = 0.8
            valid = false
        } else {
            print("over here")
            self.usernameShort.alpha = 0
            
            let characterSet:CharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789_.-")
            if !username.trimmingCharacters(in: characterSet).isEmpty {
                self.usernameInvalid.alpha = 0.8
                valid = false
            } else {
                self.usernameInvalid.alpha = 0
                print("omgomg")
                
                let docRef = db.collection("users").document(username)
                print(username)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        print("ahhhhhhhhhh")
                        self.usernameTaken.alpha = 0.8
                        valid = false
                        print("wtf", valid)
                    }
                }
            }
        }
        
        //  Check if password is at least 6 characters
        if pass.count < 6 {
            self.shortPassword.alpha = 0.8
            valid = false
        } else {
            self.shortPassword.alpha = 0
        }
        
        print(valid)
        // If all requirements are good, create the user
        if valid {
            //  Create user on Firebase Authentication
            Auth.auth().createUser(withEmail: email, password: pass) { user, error in
                if error == nil && user != nil {
                    //  Send verification email, not sure if it works
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    print("User created!")
                    
                    // Upload default profile image to Firebase Storage
                    let profile = UIImage(named: "profileIcon")
                    self.uploadProfileImage(profile){ url in
                        
                        //  Update displayName onto Firebase Authentication (is this necessary?)
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.photoURL = url
                        
                        changeRequest?.commitChanges { error in
                            if error == nil {
                                print("User display name changed!")
                                self.dismiss(animated: false, completion: nil)
                            } else {
                                print("Error: \(error!.localizedDescription)")
                            }
                        }
                        
                    }
                    
                    
            
                    
                    //  Store new user and default information into UID document
                    //                User(username: <#T##String#>, name: <#T##String#>, email: <#T##String#>, DOB: <#T##Date#>, currentLocation: <#T##CLLocationCoordinate2D?#>, currentEvent: <#T##String?#>, isPrivate: <#T##Bool?#>, friends: <#T##[String]#>, blocked: <#T##[String]#>, eventsUserHosted: <#T##[String]#>, eventsUserAttended: <#T##[String]#>, eventsUserBookmarked: <#T##[String]#>
                    
                    let new_user = User(username: username, name: name, email: email, DOB:Date(), currentLocation:CLLocationCoordinate2D(), currentEvent:"", isPrivate:false, friends:[], blocked:[], eventsUserHosted:[], eventsUserAttended:[], eventsUserBookmarked:[])
                    new_user.saveUser()
                    
//                    let uid = String(Auth.auth().currentUser!.uid)
//                    let userinfo = ["status": "green", "current_event": "", "email": email, "location": nil, "name": name, "private": false, "rating": 5, "username": username] as [String : Any?]
//                    let socialinfo = ["friends": [], "blocked": []] as [String : Any?]
//                    let eventsinfo = ["attended": [], "bookmarked": [], "hosted": [], "interested": [], "tags": [:]] as [String : Any]
//
//                    self.db.collection("users").document(uid).setData(["user_information": userinfo, "social": socialinfo, "events": eventsinfo])
//                    self.db.collection("usernames").document(username).setData(["exists": true])
                    
                } else {
                    self.emailTaken.alpha = 0.8
                }
            }
        }
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                if let url = metaData.down
                
                
                if let url = metaData?.downloadURL() {
                    completion(url)
                } else {
                    completion(nil)
                }
                // success!
            } else {
                // failed
                completion(nil)
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
