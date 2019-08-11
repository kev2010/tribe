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
                    //  Send verification email
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    print("User created!")
                    
                    //  Update displayName on Firebase Authentication
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = username
                    
                    // Upload default profile image to Firebase Storage
                    let profile = UIImage(named: "profileIcon")
                    self.uploadProfileImage(profile!){ url in
                        if url != nil {
                            //  Update photoURL onto Firebase Authentication
                            changeRequest?.photoURL = url
                            changeRequest?.commitChanges { error in
                                if error == nil {
                                    print("User display name and photoURL changed!")
                                } else {
                                    print("Error: \(error!.localizedDescription)")
                                }
                            }
                        } else {
                            // Error unable to upload profile image
                            print("Something went wrong when uploading default profile image")
                        }
                    }
                    
                    //  Create user on Firestore Database
                    let new_user = User(username:username, name:name, email:email, DOB:Date(), currentLocation:CLLocationCoordinate2D(), currentEvent:"", isPrivate:false, friends:[], blocked:[], eventsUserHosted:[], eventsUserAttended:[], eventsUserBookmarked:[])
                    new_user.saveUser()
                    
                    //  Transition to Map Screen
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    //  If there is an error with creating user with given email, then display email taken error
                    self.emailTaken.alpha = 0.8
                }
            }
        }
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        //  Retrive username and image info
        guard let username = Auth.auth().currentUser?.displayName else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        //  Create Firebase Storage reference and metaData for image
        let storageRef = Storage.storage().reference().child("users_profilepic/\(username)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        //  Store image/meta data into Firebase Storage
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else { return }
                    completion(downloadURL)
                }
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
