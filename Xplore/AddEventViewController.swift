//
//  AddEventViewController.swift
//  BoringSSL-GRPC
//
//  Created by Baptiste Bouvier on 09/08/2019.
//

import UIKit
import Firebase
import Mapbox
import CoreLocation

class AddEventViewController: UIViewController {

    @IBOutlet var title_label: UITextField!
    
    
    let datePicker = UIDatePicker()

    @IBOutlet var start_label: UITextField!
    @IBOutlet var end_label: UITextField!
    @IBOutlet var location: UITextField!
    @IBOutlet var capacity_label: UITextField!
    @IBOutlet var visibility_label: UITextField!
    @IBOutlet var tags_label: UITextField!
    @IBOutlet var description_label: UITextField!
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        showDatePicker()
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
         func showDatePicker(){
           //Formate Date
           datePicker.datePickerMode = .date

          //ToolBar
          let toolbar = UIToolbar();
          toolbar.sizeToFit()
          let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
         let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

         start_label.inputAccessoryView = toolbar
         start_label.inputView = datePicker
            
        end_label.inputAccessoryView = toolbar
        end_label.inputView = datePicker

        }

         @objc func donedatePicker(){

          let formatter = DateFormatter()
          formatter.dateFormat = "dd/MM/yyyy"
          start_label.text = formatter.string(from: datePicker.date)
          end_label.text = formatter.string(from: datePicker.date)

            self.view.endEditing(true)
        }

        @objc func cancelDatePicker(){
           self.view.endEditing(true)
         }
       

    @IBAction func saveEvent(_ sender: Any) {
        if validate(textView: title_label) &&
            validate(textView: start_label) &&
            validate(textView: end_label) &&
            validate(textView: location) &&
            validate(textView: capacity_label) &&
            validate(textView: visibility_label) &&
            validate(textView: tags_label) &&
            validate(textView: description_label) &&
            currentUser != nil {
            
            let tags = generateTags(input:tags_label.text!)
            
            // Create Address String
            
            var newLocation = CLLocationCoordinate2D()
            // Geocode Address String
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(location.text!) { (placemarks, error) in
                if let error = error {
                    print("Unable to Forward Geocode Address (\(error))")

                } else {
                    var location: CLLocation?

                    if let placemarks = placemarks, placemarks.count > 0 {
                        location = placemarks.first?.location
                    }

                    if let location = location {
                        let coordinate = location.coordinate
                        newLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        
                    } else {
                        print("No matching locations found")
                    }
                }
            }

            print("start date below:")
            print(start_label.text!)
            let newEvent = Event(creator_username: currentUser!.username, title: title_label.text!, description: description_label.text!, startDate: Date(), endDate: Date(), location: newLocation, capacity: -1, visibility: self.visibility_label.text!, tags: tags, attendees: [currentUser!.username])
            
            print(newEvent.generate_information_map())
            
//            newEvent.saveEvent()
            
            //TODO: change tags label so it's an actual array. and location. actual dates too. and capacity.
        }
        else {
            print("error: not all boxes filled out")
            // TODO: finish this implementation with a user notice or popup
        }
        
    }
//
//    func generateDate() -> String {
//        let dateFormatter = DateFormatter()
//
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .none
//        return dateFormatter.stringFromDate(sender.date)
//
//    }
    
    func generateTags(input:String) -> [String] {
        //TODO: What if they type hello, hello2 and have a space too with the comma?
        let finalTags = input.split{$0 == ","}.map(String.init)
        return finalTags
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    func validate(textView: UITextField) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            // this will be reached if the text is nil (unlikely)
            // or if the text only contains white spaces
            // or no text at all
            return false
        }

        return true
    }
    
}


