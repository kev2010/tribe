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
    
    enum DateShowing {
        case None
        case Start
        case End
    }
    var status = 0
    
    @IBOutlet var nextLabel: RoundUIView!
    
    var currentlyShowing  = DateShowing.None
    
//    var title_label = UILabel()
//    var start_label = UILabel()
//    var end_label = UILabel()
//    var location_label = UILabel()
//    var capacity_label = UILabel()
//    var visibility_label = UILabel() // public vs private w/ friends
//    var description_label = UILabel()
//    
//    var title_input = UITextField()
    var start_date = UIDatePicker()
    var end_date = UIDatePicker()
    
    var startView = UIView()
    var endView = UIView()
//    var location_input = UITextField()
//    var capacity_input = UITextField()
//    var visibility_input = UITextField()
//    var tags_input = UITextField()
//    var description_input = UITextField()
//    
//    var tagAcademic = RoundedButton()
//    var tagArts = RoundedButton()
//    var tagAthletic = RoundedButton()
//    var tagProfessional = RoundedButton()
//    var tagSocial = RoundedButton()
//    var tagCasual = RoundedButton()
    
    @IBOutlet var title_input: UITextField!
    @IBOutlet var start_input: UITextField!
    @IBOutlet var end_input: UITextField!
    @IBOutlet var description_input: UITextField!
    
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var background: RoundUIView!
    @IBOutlet weak var arrow: UIImageView!
    
    
    
    @IBOutlet weak var botUI: RoundUIView!
    @IBOutlet weak var topUI: RoundUIView!
    
    var title_label = UILabel()
    var start_label = UILabel()
    var end_label = UILabel()
    var location_label = UILabel()
    var capacity_label = UILabel()
    var visibility_label = UILabel() // public vs private w/ friends
    var description_label = UILabel()

    
    
    
    
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
        
//        title_input.attributedPlaceholder = NSAttributedString(string: "Event Title",
//        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        self.view.isUserInteractionEnabled = true
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.nextPage(_:)))
        nextLabel.addGestureRecognizer(tap3)
        nextLabel.isUserInteractionEnabled = true

//        let tap2 = UITapGestureRecognizer(target: self, action: #selector(handleNextView))
//        nextArrow.isUserInteractionEnabled = true
//        nextArrow.addGestureRecognizer(tap2)

        topUI.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        botUI.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 0.6)
        let color2 = UIColor(red: 0/255, green: 182/255, blue: 255/255, alpha: 0.6)
//        nextLabel.addGradientLayer(topColor: color1, bottomColor: color2)
//        separator.addGradientLayer(topColor: color1, bottomColor: color2)
        separator.backgroundColor = .lightGray
        background.addGradientLayer(topColor: color1, bottomColor: color2)
        arrow.setImageColor(color: .lightGray)

//        startEndUI.dropShadow()
//        descriptionUI.dropShadow()
        
//        create_all_UI()
        
        start_input.addTarget(self, action: #selector(startTouched), for: .touchDown)
        
        end_input.addTarget(self, action: #selector(endTouched), for: .touchDown)

        let frameStartView = CGRect(x: (self.view.frame.width-400-40)/2, y: self.view.frame.height, width: 400, height: 300)
        let frameEndView = CGRect(x: (self.view.frame.width-400-40)/2, y: self.view.frame.height, width: 400, height: 300)

        let frameStart = CGRect(x: 50, y: 25, width: 300, height: 250)
        let frameEnd = CGRect(x: 50, y: 25, width: 300, height: 250)


           start_date = UIDatePicker(frame: frameStart)
//            start_date.layer.borderWidth = 1
//        start_date.layer.borderColor = UIColor.black.cgColor
        
           end_date = UIDatePicker(frame: frameEnd)
//            end_date.layer.borderWidth = 1
//        end_date.layer.borderColor = UIColor.black.cgColor
        
        startView = UIView(frame: frameStartView)
        endView = UIView(frame: frameEndView)
        
        startView.backgroundColor = UIColor.white
        endView.backgroundColor = UIColor.white

        startView.addSubview(start_date)
        endView.addSubview(end_date)
        
        self.view.addSubview(startView)
        self.view.addSubview(endView)
        
//        create_all_UI()
        
//        handleNextView()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if currentlyShowing == .Start {
            showStart(show: false)
        }
        else if currentlyShowing == .End {
            showEnd(show: false)
        }
        
        
        currentlyShowing = .None

    }
    
    func close() {
        self.dismiss(animated: false, completion: {})
    }
    
    @objc func nextPage(_ sender: UITapGestureRecognizer) {
        
//        let transition = CATransition()
//        transition.duration = 0.5
//        transition.type = CATransitionType.push
//        transition.subtype = CATransitionSubtype.fromRight
//        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
//        view.window!.layer.add(transition, forKey: kCATransition)
//        present(dashboardWorkout, animated: false, completion: nil)
//
        self.performSegue(withIdentifier: "nextPage", sender: self)
    }
    
    func hide() {
        self.dismiss(animated: false, completion: {})
    }
    
    
    @objc func startTouched(textField: UITextField) {
        start_input.resignFirstResponder()
        print("start touched")
        
        if currentlyShowing == .End {
            showEnd(show: false)
            showStart(show: true)
        }
        else if currentlyShowing == .None {
            showStart(show: true)
        }
        
        currentlyShowing = .Start

    }
    
    @objc func endTouched(textField: UITextField) {
        end_input.resignFirstResponder()

        view.endEditing(true)
        
        if currentlyShowing == .Start {
            showStart(show: false)
            showEnd(show: true)
        }
        else if currentlyShowing == .None {
            showEnd(show: true)
        }
        
        currentlyShowing = .End
    }
    
    
    func showStart(show:Bool) {
        if show {
            UIView.animate(withDuration: 0.5) {
              self.startView.frame.origin.y -= 400
          }
            currentlyShowing = .Start
        }
        else {
              UIView.animate(withDuration: 0.5) {
                self.startView.frame.origin.y += 400
            }
            currentlyShowing = .None
        }
        
        
    }
    
    func showEnd(show:Bool) {
        if show {
              UIView.animate(withDuration: 0.5) {
                self.endView.frame.origin.y -= 400
            }
            currentlyShowing = .End
        }
        else {
              UIView.animate(withDuration: 0.5) {
                self.endView.frame.origin.y += 400
            }
            currentlyShowing = .None
        }
    }
//    @objc func handleNextView() -> Bool{
//        print("handling \(status)")
//        switch status {
//        case 0:
//            //SHOW TITLE
//
//            //1. Check valid: nothing to check previously
//
//            //2. Save previous value: nothing
//
//            //3. a) Remove prev labels and inputs: nothing to remove and b) add new labels and inputs: title
//
//            UIView.animate(withDuration: 1.0) {
//                self.title_label.frame.origin.x -= self.view.frame.width
//                self.title_input.frame.origin.x -= self.view.frame.width
//
//                self.start_input.frame.origin.x -= self.view.frame.width
//                self.start_label.frame.origin.x -= self.view.frame.width
//
//                self.end_label.frame.origin.x -= self.view.frame.width
//                self.end_input.frame.origin.x -= self.view.frame.width
//            }
//
//            status += 1
//            return true
//
//        case 1:
//            //SHOW START DATE
//
//            //1. Check valid: check if input text length > 0
//
//            if let t = title_input.text {
//                if t.count <= 0 {
//                    print("not")
//                    return false
//                }
//            } else {
//                print("no")
//                return false
//            }
//
//            //2. Save previous value: title
//            all_data["title"] = title_input.text
//            all_data["start"] = start_input.date
//            all_data["end"] = end_input.date
//            all_data["description"] = description_input.text
//
//
//
//            //3. a) Remove prev labels and inputs: title and b) add new labels and inputs: title
//
//            UIView.animate(withDuration: 1.0) {
//                //OLD
//                self.title_label.frame.origin.x -= self.view.frame.width
//                self.title_input.frame.origin.x -= self.view.frame.width
//
//                self.start_input.frame.origin.x -= self.view.frame.width
//                self.start_label.frame.origin.x -= self.view.frame.width
//
//                self.end_label.frame.origin.x -= self.view.frame.width
//                self.end_input.frame.origin.x -= self.view.frame.width
//
//
//                //AND NEW
//                self.tagAcademic.frame.origin.x -= self.view.frame.width
//                self.tagArts.frame.origin.x -= self.view.frame.width
//                self.tagAthletic.frame.origin.x -= self.view.frame.width
//                self.tagProfessional.frame.origin.x -= self.view.frame.width
//                self.tagSocial.frame.origin.x -= self.view.frame.width
//                self.tagCasual.frame.origin.x -= self.view.frame.width
//
//                self.capacity_label.frame.origin.x -= self.view.frame.width
//                self.capacity_input.frame.origin.x -= self.view.frame.width
//
//                self.visibility_label.frame.origin.x -= self.view.frame.width
//                self.visibility_input.frame.origin.x -= self.view.frame.width
//
//                self.location_input.frame.origin.x -= self.view.frame.width
//                self.location_label.frame.origin.x -= self.view.frame.width
//
//
//            }
//
//            status += 1
//            return true
//
//        case 2:
//            //SHOW END DATE
//
//            //1. Check valid: stuff
//
//            //Location
//            if let t = location_input.text {
//                if t.count <= 0 {
//                    return false
//                }
//            } else {
//                return false
//            }
//
//            //1. Check valid: capacity > 1
//            if let text = capacity_input.text {
//                if let num = Int(text) {
//                    if num < 2 {
//                        return false
//                    }
//                } else {
//                    return false
//                }
//            } else {
//                return false
//            }
//
//            //TODO: check valid: visibility
//
//            //TODO: check valid: tags selected
//
//            self.address_send = location_input.text!
//            self.performSegue(withIdentifier: "confirmLocation", sender: self)
//
//            //2. Save previous values
//
//            all_data["location_coord"] = finalLocationCoord
//            all_data["location_description"] = finalLocationDescription
//            all_data["capacity"] = Int(capacity_input.text!)
//            all_data["address"] = location_input.text
//            all_data["tags"] = tags_input.text
//            all_data["visibility"] = (visibility_input.text)
//
//
//            let new_event : Event = Event(creator_username: currentUser?.username ?? "", title: all_data["title"] as! String, description: all_data["description"] as! String, startDate: all_data["start"] as! Date, endDate: all_data["end"] as! Date, location: finalLocationCoord, address: all_data["address"] as! String, capacity: all_data["capacity"] as! Int, visibility: all_data["visibility"] as! String, tags: [all_data["tags"] as! String], attendees: [])
//            new_event.saveEvent()
//            //3. Dismiss view controller
//            if let presenter = self.presentingViewController as? InteractiveMap {
//                presenter.addEventsToMap(events: [(new_event, false)])
//                self.dismiss(animated: true, completion: {})
//            }
//
//        default:
//            return true
//        }
//
//        return true
//    }
    
//         func showDatePicker(){
//           //Formate Date
//           datePicker.datePickerMode = .date
//
//          //ToolBar
//          let toolbar = UIToolbar();
//          toolbar.sizeToFit()
//          let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
//            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
//         let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
//
//        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
//
//
//        }
//
//         @objc func donedatePicker(){
//
//          let formatter = DateFormatter()
//          formatter.dateFormat = "dd/MM/yyyy"
//          start_label.text = formatter.string(from: datePicker.date)
//          end_label.text = formatter.string(from: datePicker.date)
//
//            self.view.endEditing(true)
//        }

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
//    func create_all_UI() {
//        let w = self.view.frame.width
//
//        //First page
//        let frameTitle = CGRect(x: w+40+100, y: 100, width: self.view.frame.width-100-40, height: 50)
//        let frameTitleLabel = CGRect(x: w+20, y: 100, width: 100, height: 50)
//
//        let frameStart = CGRect(x: w+40+100, y: 170, width: self.view.frame.width-100-40, height: 150)
//        let frameStartLabel = CGRect(x: w+20, y: 170, width: 100, height: 30)
//
//        let frameEnd = CGRect(x: w+40+100, y: 340, width: self.view.frame.width-100-40, height: 150)
//        let frameEndLabel = CGRect(x: w+20, y: 340, width: 100, height: 30)
//
//
//        let frameDescription = CGRect(x: w+40+100, y: 510, width: self.view.frame.width-100-40, height: 100)
//        let frameDescriptionLabel = CGRect(x: w+20, y: 510, width: 100, height: 30)
//
//
//        //Second page
//        let leftTagX = w + 40
//        let rightTagX = w + 40.0 + (self.view.frame.width-100-40-20)/2 + 20.0
//        let tagWidth = (self.view.frame.width-100-40-20)/2
//
//        let frameTagsAcademic = CGRect(x: leftTagX, y: 100, width: tagWidth, height: 50)
//        let frameTagsArts = CGRect(x: rightTagX, y: 100, width: tagWidth, height: 50)
//        let frameTagsAthletic = CGRect(x: leftTagX, y: 160, width: tagWidth, height: 50)
//        let frameTagsProfessional = CGRect(x: rightTagX, y: 160, width: tagWidth, height: 50)
//        let frameTagsSocial = CGRect(x: leftTagX, y: 210, width: tagWidth, height: 50)
//        let frameTagsCasual = CGRect(x: rightTagX, y: 210, width: tagWidth, height: 50)
//
//        let frameCapacity = CGRect(x: leftTagX, y: 280, width: self.view.frame.width-100-40, height: 50)
//        let frameCapacityLabel = CGRect(x: w + 20, y: 280, width: 100, height: 30)
//
//        let frameVisibility = CGRect(x: leftTagX, y: 350, width: self.view.frame.width-100-40, height: 50)
//        let frameVisibilityLabel = CGRect(x: w+20, y: 350, width: 100, height: 30)
//
//        let frameLocation = CGRect(x: leftTagX, y: 420, width: self.view.frame.width-100-40, height: 50)
//        let frameLocationLabel = CGRect(x: w+20, y: 420, width: 100, height: 30)
//
//
//
//
//        // ZERO ----------
//           title_label = UILabel(frame: frameTitleLabel)
//           title_label.text = "Title"
//           title_label.textAlignment = .center
//            title_input = UITextField(frame: frameTitle)
//            title_input.layer.borderWidth = 1
//            title_input.layer.borderColor = UIColor.black.cgColor
//
//           view.addSubview(title_label)
//           view.addSubview(title_input)
//
//
//        // ONE ------------
//           start_label = UILabel(frame: frameStartLabel)
//           start_label.text = "Start Time"
//           start_label.textAlignment = .center
//
//           start_input = UIDatePicker(frame: frameStart)
//            start_input.layer.borderWidth = 1
//        start_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(start_label)
//           view.addSubview(start_input)
//
//
//        // TWO ------------
//           end_label = UILabel(frame: frameEndLabel)
//           end_label.text = "End Time"
//           end_label.textAlignment = .center
//
//           end_input = UIDatePicker(frame: frameEnd)
//            end_input.layer.borderWidth = 1
//            end_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(end_label)
//        view.addSubview(end_input)
//
//
//        // THREE ------------
//           location_label = UILabel(frame: frameLocationLabel)
//           location_label.text = "Event Address"
//           location_label.textAlignment = .center
//
//           location_input = UITextField(frame: frameLocation)
//            location_input.layer.borderWidth = 1
//        location_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(location_label)
//        view.addSubview(location_input)
//
//
//        // FOUR ------------
//           capacity_label = UILabel(frame: frameCapacityLabel)
//           capacity_label.text = "Capacity of Event"
//           capacity_label.textAlignment = .center
//
//           capacity_input = UITextField(frame: frameCapacity)
//            capacity_input.layer.borderWidth = 1
//        capacity_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(capacity_label)
//        view.addSubview(capacity_input)
//
//
//        // FIVE ------------
//           visibility_label = UILabel(frame: frameVisibilityLabel)
//           visibility_label.text = "Visibility of Event"
//           visibility_label.textAlignment = .center
//
//           visibility_input = UITextField(frame: frameVisibility)
//            visibility_input.layer.borderWidth = 1
//        visibility_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(visibility_label)
//        view.addSubview(visibility_input)
//
//
//        // SIX ------------
//        tagAcademic = RoundedButton(frame: frameTagsAcademic)
//        tagArts = RoundedButton(frame: frameTagsArts)
//        tagAthletic = RoundedButton(frame: frameTagsAthletic)
//        tagProfessional = RoundedButton(frame: frameTagsProfessional)
//        tagSocial = RoundedButton(frame: frameTagsSocial)
//        tagCasual = RoundedButton(frame: frameTagsCasual)
//
//
//
//        view.addSubview(tagArts)
//        view.addSubview(tagAthletic)
//        view.addSubview(tagProfessional)
//        view.addSubview(tagSocial)
//        view.addSubview(tagCasual)
//        view.addSubview(tagAcademic)
//
//        // SEVEN ------------
//           description_label = UILabel(frame: frameDescriptionLabel)
//           description_label.text = "Description"
//           description_label.textAlignment = .center
//
//           description_input = UITextField(frame: frameDescription)
//            description_input.layer.borderWidth = 1
//        description_input.layer.borderColor = UIColor.black.cgColor
//
//        view.addSubview(description_label)
//        view.addSubview(description_input)
//
//
//
//
//    }
    
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


