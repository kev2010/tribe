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
    
    var status = 0
    
    var title_label = UILabel()
    var start_label = UILabel()
    var end_label = UILabel()
    var location_label = UILabel()
    var capacity_label = UILabel()
    var visibility_label = UILabel() // public vs private w/ friends
    var tags_label = UILabel()
    var description_label = UILabel()
    
    var title_input = UITextField()
    var start_input = UIDatePicker()
    var end_input = UIDatePicker()
    var location_input = UITextField()
    var capacity_input = UITextField()
    var visibility_input = UITextField()
    var tags_input = UITextField()
    var description_input = UITextField()
    
    let datePicker = UIDatePicker()
    
    var address_send = ""
    
    var finalLocationCoord = CLLocationCoordinate2D()
    var finalLocationDescription = ""

    var all_data : [String:Any] = [String:Any]()
    
    @IBOutlet var nextArrow: UIImageView!
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
//        showDatePicker()
        
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNextView))
        nextArrow.isUserInteractionEnabled = true
        nextArrow.addGestureRecognizer(tap)
        
        create_all_UI()
        
        handleNextView()
    }
    
    @objc func handleNextView() -> Bool{
        print("handling \(status)")
        switch status {
        case 0:
            //SHOW TITLE
            
            //1. Check valid: nothing to check previously
            
            //2. Save previous value: nothing
                        
            //3. a) Remove prev labels and inputs: nothing to remove and b) add new labels and inputs: title
            
            UIView.animate(withDuration: 1.0) {
                self.title_label.frame.origin.x -= self.view.frame.width
                self.title_input.frame.origin.x -= self.view.frame.width
                
                self.start_input.frame.origin.x -= self.view.frame.width
                self.start_label.frame.origin.x -= self.view.frame.width
                
                self.end_label.frame.origin.x -= self.view.frame.width
                self.end_input.frame.origin.x -= self.view.frame.width
            }
            
            status += 1
            return true
            
        case 1:
            //SHOW START DATE
            
            //1. Check valid: check if input text length > 0
            
            if let t = title_input.text {
                if t.count <= 0 {
                    print("not")
                    return false
                }
            } else {
                print("no")
                return false
            }
            
            //2. Save previous value: title
            all_data["title"] = title_input.text
            all_data["start"] = start_input.date
            all_data["end"] = end_input.date
            all_data["description"] = description_input.text


            
            //3. a) Remove prev labels and inputs: title and b) add new labels and inputs: title

            UIView.animate(withDuration: 1.0) {
                //OLD
                self.title_label.frame.origin.x -= self.view.frame.width
                self.title_input.frame.origin.x -= self.view.frame.width
                
                self.start_input.frame.origin.x -= self.view.frame.width
                self.start_label.frame.origin.x -= self.view.frame.width
                
                self.end_label.frame.origin.x -= self.view.frame.width
                self.end_input.frame.origin.x -= self.view.frame.width
                
                
                //AND NEW
                self.tags_label.frame.origin.x -= self.view.frame.width
                self.tags_input.frame.origin.x -= self.view.frame.width
                
                self.capacity_label.frame.origin.x -= self.view.frame.width
                self.capacity_input.frame.origin.x -= self.view.frame.width
                
                self.visibility_label.frame.origin.x -= self.view.frame.width
                self.visibility_input.frame.origin.x -= self.view.frame.width
                
                self.location_input.frame.origin.x -= self.view.frame.width
                self.location_label.frame.origin.x -= self.view.frame.width
                

            }
            
            status += 1
            return true
            
        case 2:
            //SHOW END DATE
            
            //1. Check valid: stuff
            
            //Location
            if let t = location_input.text {
                if t.count <= 0 {
                    return false
                }
            } else {
                return false
            }
            
            //1. Check valid: capacity > 1
            if let text = capacity_input.text {
                if let num = Int(text) {
                    if num < 2 {
                        return false
                    }
                } else {
                    return false
                }
            } else {
                return false
            }
            
            //TODO: check valid: visibility
            
            //TODO: check valid: tags selected
            
            self.address_send = location_input.text!
            self.performSegue(withIdentifier: "confirmLocation", sender: self)
            
            //2. Save previous values
            
            all_data["location_coord"] = finalLocationCoord
            all_data["location_description"] = finalLocationDescription
            all_data["capacity"] = Int(capacity_input.text!)
            all_data["address"] = location_input.text
            all_data["tags"] = tags_input.text
            all_data["visibility"] = (visibility_input.text)

            
            let new_event : Event = Event(creator_username: currentUser?.username ?? "", title: all_data["title"] as! String, description: all_data["description"] as! String, startDate: all_data["start"] as! Date, endDate: all_data["end"] as! Date, location: finalLocationCoord, address: all_data["address"] as! String, capacity: all_data["capacity"] as! Int, visibility: all_data["visibility"] as! String, tags: [all_data["tags"] as! String], attendees: [])
            new_event.saveEvent()
            //3. Dismiss view controller
            if let presenter = self.presentingViewController as? InteractiveMap {
                presenter.addEventsToMap(events: [new_event])
                self.dismiss(animated: true, completion: {})
            }
            
        default:
            return true
        }
        
        return true
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
       


//    @IBAction func saveEvent(_ sender: Any) {
//        if validate(textView: title_label) &&
//            validate(textView: start_label) &&
//            validate(textView: end_label) &&
//            validate(textView: location) &&
//            validate(textView: capacity_label) &&
//            validate(textView: visibility_label) &&
//            validate(textView: tags_label) &&
//            validate(textView: description_label) &&
//            currentUser != nil {
//            
//            let tags = generateTags(input:tags_label.text!)
//            
//            // Create Address String
//            
//            var newLocation = CLLocationCoordinate2D()
//            // Geocode Address String
//            
//            let geocoder = CLGeocoder()
//            geocoder.geocodeAddressString(location.text!) { (placemarks, error) in
//                if let error = error {
//                    print("Unable to Forward Geocode Address (\(error))")
//
//                } else {
//                    var location: CLLocation?
//
//                    if let placemarks = placemarks, placemarks.count > 0 {
//                        location = placemarks.first?.location
//                    }
//
//                    if let location = location {
//                        let coordinate = location.coordinate
//                        newLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
//                        
//                    } else {
//                        print("No matching locations found")
//                    }
//                }
//            }
//
//            print("start date below:")
//            print(start_label.text!)
//            let newEvent = Event(creator_username: currentUser!.username, title: title_label.text!, description: description_label.text!, startDate: Date(), endDate: Date(), location: newLocation, capacity: -1, visibility: self.visibility_label.text!, tags: tags, attendees: [currentUser!.username])
//            
//            print(newEvent.generate_information_map())
//            
////            newEvent.saveEvent()
//            
//            //TODO: change tags label so it's an actual array. and location. actual dates too. and capacity.
//        }
//        else {
//            print("error: not all boxes filled out")
//            // TODO: finish this implementation with a user notice or popup
//        }
//        
//    }

//
//
//
//            let newEvent = Event(creator_username: currentUser!.username, title: title_label.text!, description: description_label.text!, startDate: Date(), endDate: Date(), location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), capacity: -1, visibility: self.visibility_label.text!, tags: tags, attendees: [currentUser!.username])
//
//            print(newEvent.generate_information_map())
//
////            newEvent.saveEvent()
//
//            //TODO: change tags label so it's an actual array. and location. actual dates too. and capacity.
//        }
//        else {
//            print("error: not all boxes filled out")
//            // TODO: finish this implementation with a user notice or popup
//        }
//
//    }
//
    func create_all_UI() {
        
        //First page
        let frameTitle = CGRect(x: 40, y: 100, width: self.view.frame.width-100-40, height: 50)
        let frameTitleLabel = CGRect(x: 20, y: 100, width: 100, height: 50)

        let frameStart = CGRect(x: 40, y: 170, width: self.view.frame.width-100-40, height: 150)
        let frameStartLabel = CGRect(x: 20, y: 170, width: 100, height: 30)

        let frameEnd = CGRect(x: 40, y: 340, width: self.view.frame.width-100-40, height: 150)
        let frameEndLabel = CGRect(x: 20, y: 340, width: 100, height: 30)

        let frameDescription = CGRect(x: 40, y: 510, width: self.view.frame.width-100-40, height: 100)
        let frameDescriptionLabel = CGRect(x: 20, y: 510, width: 100, height: 30)


        //Second page
        let frameTagsAcademic = CGRect(x: self.view.frame.width*(1+1/6), y: 100, width: self.view.frame.width*(2/3), height: 50)
        let frameTagsArts = CGRect(x: self.view.frame.width*(1+1/6), y: 100, width: self.view.frame.width*(2/3), height: 50)
        let frameTagsAthletic = CGRect(x: self.view.frame.width*(1+1/6), y: 160, width: self.view.frame.width*(2/3), height: 50)
        let frameTagsProfessional = CGRect(x: self.view.frame.width*(1+1/6), y: 160, width: self.view.frame.width*(2/3), height: 50)
        let frameTagsSocial = CGRect(x: self.view.frame.width*(1+1/6), y: 210, width: self.view.frame.width*(2/3), height: 50)
        let frameTagsCasual = CGRect(x: self.view.frame.width*(1+1/6), y: 210, width: self.view.frame.width*(2/3), height: 50)

        let frameCapacity = CGRect(x: self.view.frame.width*(1+1/6), y: 280, width: self.view.frame.width*(2/3), height: 50)
        let frameVisibility = CGRect(x: self.view.frame.width*(1+1/6), y: 350, width: self.view.frame.width*(2/3), height: 50)
        let frameLocation = CGRect(x: self.view.frame.width*(1+1/6), y: 420, width: self.view.frame.width*(2/3), height: 50)



        // ZERO ----------
           title_label = UILabel(frame: frameTitle)
           title_label.text = "Title"
           title_label.textAlignment = .center
    
            title_input = UITextField(frame: frameTitle)
            title_input.layer.borderWidth = 1
            title_input.layer.borderColor = UIColor.black.cgColor
            title_input.placeholder = "Title"
        
           view.addSubview(title_label)
           view.addSubview(title_input)
//
//
//        // ONE ------------
//           start_label = UILabel(frame: f)
//           start_label.text = "Start Time"
//           start_label.textAlignment = .center
//
//           start_input = UIDatePicker(frame: fDate)
//            start_input.layer.borderWidth = 1
//        start_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(start_label)
//           view.addSubview(start_input)
//
//
//        // TWO ------------
//           end_label = UILabel(frame: f)
//           end_label.text = "End Time"
//           end_label.textAlignment = .center
//
//           end_input = UIDatePicker(frame: fDate)
//            end_input.layer.borderWidth = 1
//            end_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(end_label)
//        view.addSubview(end_input)
//
//
//        // THREE ------------
//           location_label = UILabel(frame: f)
//           location_label.text = "Event Address"
//           location_label.textAlignment = .center
//
//           location_input = UITextField(frame: f2)
//            location_input.layer.borderWidth = 1
//        location_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(location_label)
//        view.addSubview(location_input)
//
//
//        // FOUR ------------
//           capacity_label = UILabel(frame: f)
//           capacity_label.text = "Capacity of Event"
//           capacity_label.textAlignment = .center
//
//           capacity_input = UITextField(frame: f2)
//            capacity_input.layer.borderWidth = 1
//        capacity_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(capacity_label)
//        view.addSubview(capacity_input)
//
//
//        // FIVE ------------
//           visibility_label = UILabel(frame: f)
//           visibility_label.text = "Visibility of Event"
//           visibility_label.textAlignment = .center
//
//           visibility_input = UITextField(frame: f2)
//            visibility_input.layer.borderWidth = 1
//        visibility_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(visibility_label)
//        view.addSubview(visibility_input)
//
//
//        // SIX ------------
//           tags_label = UILabel(frame: f)
//           tags_label.text = "Event Tags"
//           tags_label.textAlignment = .center
//
//           tags_input = UITextField(frame: f2)
//            tags_input.layer.borderWidth = 1
//        tags_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(tags_label)
//        view.addSubview(tags_input)
//
//
//        // SEVEN ------------
//           description_label = UILabel(frame: f)
//           description_label.text = "Description"
//           description_label.textAlignment = .center
//
//           description_input = UITextField(frame: f2)
//            description_input.layer.borderWidth = 1
//        description_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(description_label)
//        view.addSubview(description_input)
//
//
        
          
    }
    
    func generateTags(input:String) -> [String] {
        //TODO: What if they type hello, hello2 and have a space too with the comma?
        let finalTags = input.split{$0 == ","}.map(String.init)
        return finalTags
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "confirmLocation" {
            let vc = segue.destination as! PickAddressViewController
            vc.address = self.address_send
        }
    }


    
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


