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
import FirebaseStorage

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
        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 1)
        let color2 = UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
        //        let color2 = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        view.addGradientLayer(topColor: color1, bottomColor: color2)
        
        //  Dismiss keyboard when user taps outside
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        nameField.delegate = self
        emailField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            usernameField.becomeFirstResponder()
        } else if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            passwordField.resignFirstResponder()
        }
        return true
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        
        //  Initialize dispatch group to contorl threading priority
        let check = DispatchGroup()
        
        //  Check if any field is empty and email has "@"
        if name == "" || email == "" || username == "" || !email.contains("@") {
            self.missingFields.alpha = 0.6
            valid = false
        } else {
            self.missingFields.alpha = 0
        }
    
        //  Check if username has valid syntax and doesn't already exist
        if username.count < 3 {
            self.usernameShort.alpha = 0.6
            valid = false
        } else {
            self.usernameShort.alpha = 0
            
            let characterSet:CharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789_.-")
            if !username.trimmingCharacters(in: characterSet).isEmpty {
                self.usernameInvalid.alpha = 0.6
                valid = false
            } else {
                self.usernameInvalid.alpha = 0
                
                let docRef = db.collection("users").document(username)
                check.enter()
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.usernameTaken.alpha = 0.6
                        valid = false
                    } else {
                        self.usernameTaken.alpha = 0
                    }
                    check.leave()
                }
            }
        }
    
        //  Check if password is at least 6 characters
        if pass.count < 6 {
            self.shortPassword.alpha = 0.6
            valid = false
        } else {
            self.shortPassword.alpha = 0
        }
        
        // Create the user once all requirements have been checked
        check.notify(queue: DispatchQueue.main) {
            if valid {
                print(valid)
                //  Create user on Firebase Authentication
                Auth.auth().createUser(withEmail: email, password: pass) { user, error in
                    if error == nil && user != nil {
                        //  Send verification email
                        Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                        
                        //  Update displayName and photoURL Firebase Authentication
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        
                        // Upload default profile image to Firebase Storage
                        let profile = self.createDefaultImage(drawText: name[0])
                        check.enter()
                        self.uploadProfileImage(profile){ url in
                            if url != nil {
                                //  Update photoURL onto Firebase Authentication
                                changeRequest?.displayName = username
                                changeRequest?.photoURL = url
                                changeRequest?.commitChanges { error in
                                    if error == nil {
                                        print("User display name and photoURL changed!")
                                    } else {
                                        print("Error: \(error!.localizedDescription)")
                                    }
                                    check.leave()
                                }
                            } else {
                                // Error unable to upload profile image
                                print("Something went wrong when uploading default profile image")
                            }
                        }
                        
                        //  Create user on Firestore Database
                        let new_user = User(uid: Auth.auth().currentUser!.uid, username:username, name:name, email:email, DOB:Date(), currentLocation:CLLocationCoordinate2D(), currentEvent:[], privacy:"public", friends:[], friend_req:[], blocked:[], eventsUserHosted:[], eventsUserAttended:[], eventsUserBookmarked:[])
                        new_user.saveUser()
                        currentUser = new_user
                        
                        //  Once user has been created, transition to Map Screen
                        check.notify(queue: DispatchQueue.main) {
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                    } else {
                        //  If there is an error with creating user with given email, then display email taken error
                        print("huh")
                        self.emailTaken.alpha = 0.6
                    }
                }
            }
        }
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        //  Retrieve username and image info
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        //  Create Firebase Storage reference and metaData for image
        let storageRef = Storage.storage().reference().child("users_profilepic/\(uid)")
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
    
    func createDefaultImage(drawText text: String) -> UIImage {
        //  Define text attribute values and initialize image
        let textColor = UIColor.white
        let textFont = UIFont(name: "Futura-Bold", size: 48)!
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        let image = UIColor.init(red: 0, green: 255/255, blue: 194/255, alpha: 1).image(CGSize(width: 128, height: 128))
        
        //  Draw in image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        //  Draw in text
        let size = (text as NSString).size(withAttributes: textFontAttributes)
        let text_x = (image.size.width - size.width)/2
        let text_y = (image.size.height - size.height)/2
        let rect = CGRect(origin: CGPoint(x: text_x, y: text_y), size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        //  Create UIImage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
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

extension UIColor {
    //  Creates an Image with one solid color
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
