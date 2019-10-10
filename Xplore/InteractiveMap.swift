//
//  InteractiveMap.swift
//  Xplore
//
//  Created by Kevin Jiang on 8/2/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Mapbox
import Firebase
import FirebaseStorage

class InteractiveMap: UIViewController, UITableViewDataSource, UITableViewDelegate, MGLMapViewDelegate, CLLocationManagerDelegate{
    
    let manager = CLLocationManager()
    let db = Firestore.firestore()
    
    //  Used for Settings Screen
    var window: UIWindow?
    
    var currentLocation = CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
    var previousLocation = CLLocationCoordinate2D.init(latitude: 0.1, longitude: 0.1)
    
    //  Used for Friends Screen
    var friends:[Friend] = []

    
    //  Bottom tile variables - global
    var topTileShowing = false
    var topTile = UIView()
    var bottom_titleLabel = UILabel()
    var bottom_subtitleLabel = UILabel()
    var bottom_descriptionLabel = UILabel()
    
    //  Big tile variablees - global
    var bigTile = UIView()
    var big_titleLabel = UILabel()
    var big_subtitleLabel = UILabel()
    var big_entranceLabel  = UILabel()
    var big_descriptionLabel = UILabel()
    var big_exitButton = UIButton()
    
    var leftMenuView = UIView()
    var mapView = MGLMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var rightFriendsView = UITableView()
    
    var bottomMenu_main = UIButton()
    var bottomMenu_map = UIButton()
    var bottomMenu_friends = UIButton()
    
    var imagePicker = UIImagePickerController()
    var profile = UIImageView()
    
    
    enum screen {
        case Main
        case Map
        case Friends
    }
    
    var currentScreen = screen.Map
    
    @IBAction func toHome(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toMain", sender: self)
    }
    
    func addRandomEvents() ->  [Event]{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        var start = formatter.date(from: "2019/08/06 21:00")
        var end = formatter.date(from: "2019/08/06 23:00")

        
        let event_1 : Event = Event(creator_username: "new", title: "Phi Sig Party", description: "Come to Phi Sig for cages, Mo's dancing and a wild party that won't get shut down at 11pm", startDate: start!, endDate: end!, location: CLLocationCoordinate2D(latitude: 37.779834, longitude: -122.39941), capacity: 50, visibility: "PUBLIC", tags: ["party", "cages"], attendees: ["kevin"])
        
        start = formatter.date(from: "2019/08/08 20:00")
        end = formatter.date(from: "2019/08/08 23:00")
        
        let event_2 : Event = Event(creator_username: "new", title: "Kevin's room", description: "Poker night, texas holdem. Come and get destroyed by the king of poker himself.", startDate: start!, endDate: end!, location: CLLocationCoordinate2D(latitude: 37.791834, longitude: -122.41017), capacity: 15, visibility: "FRIENDS", tags: ["poker", "games"], attendees: ["kevin"])
        
        let allEvents = [event_1, event_2]
        
        for event in allEvents {
            event.saveEvent()
        }
        
        return allEvents
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        FriendsAPI.getFriends() // model
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: Notification.Name("didDownloadFriends"), object: nil)
        
        print("What's going on?")
        print(friends)
        
        self.createThreeViewUI()
        
        loadAndAddEvents()
        
        // Configure location manager to user's location
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        loadBottomTile()
        loadBigTile()
        
        let timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(saveUserLocation), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        if let data = notification.object as? [Friend]
        {
            friends = data
            rightFriendsView.reloadData()
        }
                
    }
    
    func loadAndAddEvents(){
        
        var allEvents : [Event] = []
        
        db.collection("events").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("found one")
                for document in querySnapshot!.documents {
                    let e = Event(QueryDocumentSpapshot: document)
                    allEvents.append(e)
                    print("distance")
                    print(self.distanceBetweenTwoCoordinates(loc1: self.currentLocation, loc2: e.location))
                }
                
                
                self.addEventsToMap(events: allEvents)
            }
        }
        
        
        
    }
    
    func addEventsToMap(events:[Event]) {
        
        // Fill an array with point annotations and add it to the map.
        var pointAnnotations = [CustomPointAnnotation]()
        for event in events {
            let point = CustomPointAnnotation(coordinate: event.location, title: event.title, subtitle: "\(event.capacity) people", description: event.description)
            point.reuseIdentifier = "customAnnotation\(event.title)"
            point.image = dot(size: 30, num: event.capacity)
            pointAnnotations.append(point)
        }
        
        mapView.addAnnotations(pointAnnotations)
    }
    
    // MARK: - Create UI
    
    func createThreeViewUI() {
        self.createLeftMenu()
        self.createMiddleMap()
        self.createRightFriends()
        
        
    }
    
    func createLeftMenu() {
        
        //  Logout Button - move to settings in future
//        let f3 = CGRect(x: self.view.frame.width/2-60, y: 5*self.view.frame.height/6, width: 100, height: 50)
//        let logout_button = UIButton(frame: f3)
//        logout_button.setTitle("Logout", for: UIControl.State.normal)
//        logout_button.addTarget(self, action: #selector(self.logout), for: UIControl.Event.touchDown)

        //  Create the top background
        let topbackground = UIImageView(frame: CGRect(x: -243, y: -580, width: 900, height: 900))
        topbackground.layer.cornerRadius = topbackground.bounds.height/2
        topbackground.clipsToBounds = true
        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 1)
        let color2 = UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
        topbackground.addGradientLayer(topColor: color1, bottomColor: color2, start: CGPoint(x: 1, y: 1), end: CGPoint(x: 0, y: 1))
        
        //  Create the bottom background
        let f = CGRect(x: -self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        leftMenuView = UIView(frame: f)
        leftMenuView.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
//        let topcircle = UIBezierPath(arcCenter: CGPoint(x: self.view.frame.width/2, y: -130), radius: CGFloat(450), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi*2), clockwise: true)
//        let topbackground = CAShapeLayer()
//        topbackground.path = topcircle.cgPath
//        topbackground.fillColor = UIColor(red: 58/255, green: 68/255, blue: 84/255, alpha: 1).cgColor
        
        //  Add settings button
        let settings_button = UIButton(type: UIButton.ButtonType.custom)
        settings_button.frame = CGRect(x: 19, y: 45, width: 36, height: 36)
        settings_button.setImage(UIImage(named: "settings"), for: .normal)
        settings_button.addTarget(self, action: #selector(self.goSettings), for: UIControl.Event.touchDown)
        
        //  Add "Bookmarked Events" title
        let bookmarklabel = UILabel(frame: CGRect(x: 118, y: 343, width: 206, height: 23))
        let bookmarkpic = UIImageView(frame: CGRect(x: 90, y: 338, width: 28, height: 31))
        bookmarklabel.text = "Bookmarked Events"
        bookmarklabel.textAlignment = .center
        bookmarklabel.textColor = UIColor(red: 58/255, green: 68/255, blue: 84/255, alpha: 1)
        bookmarklabel.font = UIFont(name: "TrebuchetMS-Bold", size: 22)
        bookmarkpic.image = UIImage(named: "bookmark")
        
        //  Retrieve profile picture from Firebase Storage
        let ppRef = Storage.storage().reference(withPath: "users_profilepic/\(Auth.auth().currentUser!.uid)")
        ppRef.getData(maxSize: 1 * 1024 * 1024) { data, error in    // Might need to change size?
            if let error = error {
                print("Error in retrieving image: \(error.localizedDescription)")
            } else {
                let image = UIImage(data: data!)
                self.profile.image = image
            }
        }
        //  Add specifics to picture
        profile.frame = CGRect(x: 133, y: 82, width: 148, height: 148)
        profile.layer.cornerRadius = profile.bounds.height/2
        profile.clipsToBounds = true
        //  Add ability to change profile pic
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(changeImage))
        profile.isUserInteractionEnabled = true
        profile.addGestureRecognizer(imageTap)
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        //  Add status - Need to add to database?
        let statuspath = UIBezierPath(arcCenter: CGPoint(x: 259.3, y: 208.3), radius: CGFloat(12.5), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi*2), clockwise: true)
        let status = CAShapeLayer()
        status.path = statuspath.cgPath
        status.fillColor = UIColor.green.cgColor
        
        //  Add Name under profile picture

        let username = currentUser!.username
        let docRef = db.collection("users").document(username)
        
        let namelabel = UILabel(frame: CGRect(x: 0, y: 237, width: 414, height: 23))
        namelabel.text = currentUser!.username
//        db.collection("users").document(username!).getDocument { (document, error) in
//            if let document = document, document.exists {
//                //                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                namelabel.text = ((document.data()!["user_information"] as! [String:Any])["name"] as! String)
//            } else {
//                print("Document does not exist")
//            }
//        }
        namelabel.textAlignment = .center
        namelabel.textColor = UIColor.white
        namelabel.font = UIFont(name: "TrebuchetMS-Bold", size: 20)
        
        //  Add Username under Name
        let usernamelabel = UILabel(frame: CGRect(x: 0, y: 263, width: 414, height: 14))
        usernamelabel.text = Auth.auth().currentUser!.displayName
        usernamelabel.textAlignment = .center
        usernamelabel.textColor = UIColor.white
        usernamelabel.font = UIFont(name: "TrebuchetMS", size: 14)
        
        
        //  Add event tiles
        
        //  Create a vertical scrollview
        
        //  Retrieve all of user's bookmarked events
        var bookmarks : [(time_left: Date, event: UIButton)] = []
        for eventRef in currentUser!.eventsUserBookmarked {
            let eventtile = UIButton()
            eventtile.backgroundColor = UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
            var buttonText : NSString = ""
            
            db.collection("events").document(eventRef.documentID).getDocument { (document, error) in
                if let document = document, document.exists {
                    //                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                    namelabel.text = ((document.data()!["user_information"] as! [String:Any])["name"] as! String)
                    let title = (document.data()!["information"] as! [String:Any])["title"] as! NSString
                    let creator = (document.data()!["attendees"] as! [String:Any])["creator_username"]
                    buttonText = (document.data()!["information"] as! [String:Any])["title"] as! NSString //TODO WHAT IS THIS?
                } else {
                    print("Document does not exist")
                }
            }
            
            //applying the line break mode
            eventtile.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
            
//            let buttonText: NSString = "hello\nthere"
            
            //getting the range to separate the button title strings
            let newlineRange: NSRange = buttonText.range(of: "\n")
            
            //getting both substrings
            var substring1: NSString = ""
            var substring2: NSString = ""
            
            if(newlineRange.location != NSNotFound) {
                substring1 = buttonText.substring(to: newlineRange.location) as NSString
                substring2 = buttonText.substring(from: newlineRange.location) as NSString
            }
            
            //assigning diffrent fonts to both substrings
            let font:UIFont? = UIFont(name: "Arial", size: 17.0)
            let attrString = NSMutableAttributedString(
                string: substring1 as String,
                attributes: (NSDictionary(
                    object: font!,
                    forKey: NSAttributedString.Key.font as NSCopying) as [NSObject : AnyObject] as [NSObject : AnyObject] as! [NSAttributedString.Key : Any]))
            
            let font1:UIFont? = UIFont(name: "Arial", size: 11.0)
            let attrString1 = NSMutableAttributedString(
                string: substring2 as String,
                attributes: (NSDictionary(
                    object: font1!,
                    forKey: NSAttributedString.Key.font as NSCopying) as [NSObject : AnyObject] as [NSObject : AnyObject] as! [NSAttributedString.Key : Any]))
            
            //appending both attributed strings
            attrString.append(attrString1)
            
            //assigning the resultant attributed strings to the button
            eventtile.setAttributedTitle(attrString, for: .normal)
            
            
//            bookmarks.append(())
        }
        
        
        //  Sort by start date? - Might want to customize sorting in the future
        
        
        
        
        
        //(334, 812)
        //(414, 896)
        //  Add all the subviews to the left menu
//        leftMenuView.layer.addSublayer(topbackground)
        leftMenuView.addSubview(topbackground)
        leftMenuView.addSubview(settings_button)
        leftMenuView.addSubview(profile)
        leftMenuView.layer.addSublayer(status)
        leftMenuView.addSubview(namelabel)
        leftMenuView.addSubview(usernamelabel)
        leftMenuView.addSubview(bookmarklabel)
        leftMenuView.addSubview(bookmarkpic)
        self.view.addSubview(leftMenuView)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanLeft))
        leftMenuView.addGestureRecognizer(gestureRecognizer)
        
        
    }
    
    func createMiddleMap() {
        //Load map view
        mapView = MGLMapView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
//        mapView.styleURL = URL(string: "mapbox://styles/kev2018/cjytf3psp05u71cqm0l0bacgt")
        mapView.styleURL = URL(string: "mapbox://styles/kev2018/cjytijoug092v1cqz0ogvzb0w")
        mapView.delegate = self
        
        //Add map and button to scroll view
        self.view.addSubview(mapView)
        
        let f2 = CGRect(x: self.view.frame.width/2-150, y: 3*self.view.frame.height/4, width: 70, height: 70)
        bottomMenu_main = UIButton(frame: f2)
        bottomMenu_main.addTarget(self, action: #selector(self.goMain), for: UIControl.Event.touchDown)
        bottomMenu_main.setImage(UIImage(named: "home.png"), for: UIControl.State.normal)
        
        let f3 = CGRect(x: self.view.frame.width/2-50, y: 3*self.view.frame.height/4, width: 70, height: 70)
        bottomMenu_map = UIButton(frame: f3)
        bottomMenu_map.addTarget(self, action: #selector(self.goMap), for: UIControl.Event.touchDown)
        bottomMenu_map.setImage(UIImage(named: "100_new_event.png"), for: UIControl.State.normal)
        
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
//        self.bottomMenu_map.addGestureRecognizer(longPressRecognizer)
        
//        bottomMenu_map_new = UIButton(frame:f3)
//        bottomMenu_map_new.addTarget(self, action: #selector(self.goMap), for: UIControl.Event.touchDown)


        
        let f4 = CGRect(x: self.view.frame.width/2+50, y: 3*self.view.frame.height/4, width: 70, height: 70)
        bottomMenu_friends = UIButton(frame: f4)
        bottomMenu_friends.addTarget(self, action: #selector(self.goFriends), for: UIControl.Event.touchDown)
        bottomMenu_friends.setImage(UIImage(named: "friends.png"), for: UIControl.State.normal)

        
        self.view.addSubview(bottomMenu_main)
        self.view.addSubview(bottomMenu_map)
        self.view.addSubview(bottomMenu_friends)
        
        self.view.bringSubviewToFront(bottomMenu_main)
        self.view.bringSubviewToFront(bottomMenu_map)
        self.view.bringSubviewToFront(bottomMenu_friends)
        
        let f5 = CGRect(x: 2*self.view.frame.width/3, y: 50, width: 100, height: 50)
        let filter_button = UIButton(frame: f5)
        filter_button.setTitle("Filter", for: UIControl.State.normal)
        filter_button.addTarget(self, action: #selector(self.goFilter), for: UIControl.Event.touchDown)
        
        mapView.addSubview(filter_button)
        
        
        
    }
    
    func createRightFriends() {
        //  Add Background gradient
//        let f = CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
//        rightFriendsView = UIView(frame: f)
        rightFriendsView = UITableView()
        
        rightFriendsView.dataSource = self
        rightFriendsView.delegate = self
        rightFriendsView.register(FriendsCell.self, forCellReuseIdentifier: "friendCell")
        
       
//        rightFriendsView.alpha = 1
//        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 1)
//        let color2 = UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
//        self.view.addGradientLayer(topColor: color1, bottomColor: color2)
//        rightFriendsView.addGradientLayer(topColor: color1, bottomColor: color2)
//        rightFriendsView.backgroundColor = color1
        self.view.addSubview(rightFriendsView)
        rightFriendsView.frame = CGRect(x: self.view.frame.width, y: 200, width: self.view.frame.width, height: self.view.frame.height)
        rightFriendsView.tableFooterView = UIView()
        
        
        
//        rightFriendsView.dataSource = self
        
        
//        let friendsTableView = UIView(frame: f)
//        friendsTableView.backgroundColor = UIColor.blue
//        self.view.addSubview(friendsTableView)
//        rightFriendsView.translatesAutoresizingMaskIntoConstraints = false
//        rightFriendsView.topAnchor.constraint(equalTo:view.topAnchor).isActive = true
//        friendsTableView.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
//        friendsTableView.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
//        rightFriendsView.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true


        
//        let f2 = CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: 30)
//        let randomLabel = UILabel(frame: f2)
//        randomLabel.text = "lol you have no friends"
//        randomLabel.textAlignment = .center
//
//        rightFriendsView.addSubview(randomLabel)
//        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanRight))
//        rightFriendsView.addGestureRecognizer(gestureRecognizer)

//        contactsTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "contactCell")


//        self.view.addSubview(friendsTableView)
//        self.view.bringSubviewToFront(friendsTableView)
        
//        rightFriendsView.reloadData()

    }
    
    //  protocol methods for Friends UITable
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ugh")
        print(friends.count)
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("ahh")
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsCell
//        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        print("**")
        print(friends[indexPath.row].name)
//        cell.textLabel?.text = friends[indexPath.row].name
        cell.friend = friends[indexPath.row]
        rightFriendsView.bringSubviewToFront(cell)
        view.bringSubviewToFront(rightFriendsView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(friends[indexPath.row].name)
        self.goMap()
    }
    
    @objc func handlePanLeft(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("yay left")
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            
            let translation = gestureRecognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            
            if translation.x < 0 {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y)
                mapView.center = CGPoint(x: mapView.center.x + translation.x, y: mapView.center.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
        }
            
        else if gestureRecognizer.state == .ended {
            print(mapView.center.x, self.view.frame.width)
            if mapView.center.x > self.view.frame.width {
                goMain()
            }
            else {
                goMap()
            }
        }
    }
    
    @objc func handlePanRight(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            
            let translation = gestureRecognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            
            if translation.x > 0 {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y)
                mapView.center = CGPoint(x: mapView.center.x + translation.x, y: mapView.center.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
        }
            
        else if gestureRecognizer.state == .ended {
            print(mapView.center.x, self.view.frame.width)
            if mapView.center.x > 0 {
                goMap()
            }
            else {
                goFriends()
            }
        }
    }
    
    // MARK: - MGLMapViewDelegate methods
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let point = annotation as? CustomPointAnnotation,
            let image = point.image,
            let reuseIdentifier = point.reuseIdentifier {
            
            if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier) {
                // The annotatation image has already been cached, just reuse it.
                return annotationImage
            } else {
                // Create a new annotation image.
                return MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
            }
        }
        
        // Fallback to the default marker image.
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if let point = annotation as? CustomPointAnnotation {
            
            if topTileShowing {
                bottom_titleLabel.text = point.title!
                bottom_subtitleLabel.text  = point.subtitle!
                bottom_descriptionLabel.text = point.desc!
            }
            else {
                
                bottom_titleLabel.text = point.title!
                bottom_subtitleLabel.text  = point.subtitle!
                bottom_descriptionLabel.text = point.desc!
                
                showTopTile(show: true)
                topTileShowing = true
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        if topTileShowing {
            showTopTile(show: false)
            topTileShowing = false
        }  else {
            print("here")
            showBigTile(show: false)
        }
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        print("JUST CHANGED")
        
        OperationQueue.main.addOperation
            {() -> Void in
                
                //  do some UI stuff
                
                
//                let zoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width
//                let newAnnotations = self.annotationsWithinRect(rect:mapView.visibleMapRect, zoomScale:zoomScale)
//
//                self.updateMapViewAnnotationsWithAnnotations(annotations: newAnnotations)
        }
        
    
    }

    func annotationsWithinRect(rect:MGLCoordinateBounds, zoomScale:Double) -> [MGLAnnotation] {
        
        return []
    }
    
    func updateMapViewAnnotationsWithAnnotations(annotations:[MGLAnnotation]) {
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //  Determine user's current location and save boundaries
        let location = locations[0]
        let botleft = CLLocationCoordinate2D(latitude: location.coordinate.latitude - 0.01, longitude: location.coordinate.longitude - 0.01)
        let topright = CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.01, longitude: location.coordinate.longitude + 0.01)
        let region:MGLCoordinateBounds = MGLCoordinateBounds(sw: botleft, ne: topright)
        
        //  Display the user's region onto screen
        mapView.setVisibleCoordinateBounds(region, animated: false)
        mapView.showsUserLocation = true
        
        
        currentLocation = location.coordinate
    }
    
    @objc func saveUserLocation() {
        if !(currentLocation.latitude == previousLocation.latitude && currentLocation.longitude == previousLocation.longitude){
            
            previousLocation = currentLocation
            
            if currentUser != nil {
                
            currentUser!.currentLocation = currentLocation
            currentUser!.updateUser()
                
            }
        }
    }
    
    // MARK: - Navigation

    @objc func goMain() {
                
        currentScreen = .Main
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [UIView.AnimationOptions.curveEaseInOut], animations: {
            self.leftMenuView.frame.origin = CGPoint(x: 0, y: 0)
            self.mapView.frame.origin = CGPoint(x: self.view.frame.width, y: 0)
            self.rightFriendsView.frame.origin = CGPoint(x: 2*self.view.frame.width, y: 0)
        }) { (true) in
            
            self.view.bringSubviewToFront(self.bottomMenu_main)
            self.view.bringSubviewToFront(self.bottomMenu_map)
            self.view.bringSubviewToFront(self.bottomMenu_friends)
            
            self.bottomMenu_map.setImage(UIImage(named: "map.png"), for: UIControl.State.normal)
            self.bottomMenu_main.setImage(UIImage(named: "100_home.png"), for: UIControl.State.normal)
            self.bottomMenu_friends.setImage(UIImage(named: "friends.png"), for: UIControl.State.normal)

            
            
        }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longpressed")

        
    }
    
    func showExtraButtons() {
        //do animations to show add event and filter buttons
        UIView.animate(withDuration: 0.2) {
            
        }
        self.performSegue(withIdentifier: "mapToAddEvent", sender: self)

    }
    
    @objc func goMap() {
        print("to map")
        if currentScreen == .Map {
            showExtraButtons()
            return
        }
        
        
        
        currentScreen = .Map
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [UIView.AnimationOptions.curveEaseInOut], animations: {
            self.leftMenuView.frame.origin = CGPoint(x: -self.view.frame.width, y: 0)
            self.mapView.frame.origin = CGPoint(x: 0, y: 0)
            self.rightFriendsView.frame.origin = CGPoint(x: self.view.frame.width, y: 0)
            
        }) { (true) in
            
            self.bottomMenu_map.setImage(UIImage(named: "100_new_event.png"), for: UIControl.State.normal)
            self.bottomMenu_main.setImage(UIImage(named: "home.png"), for: UIControl.State.normal)
            self.bottomMenu_friends.setImage(UIImage(named: "friends.png"), for: UIControl.State.normal)

            
            
            self.view.bringSubviewToFront(self.bottomMenu_main)
            self.view.bringSubviewToFront(self.bottomMenu_map)
            self.view.bringSubviewToFront(self.bottomMenu_friends)
            
            
        }
        
    }
    
    @objc func goFriends() {
        currentScreen = .Friends
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [UIView.AnimationOptions.curveEaseInOut], animations: {
            self.leftMenuView.frame.origin = CGPoint(x: -2*self.view.frame.width, y: 0)
            self.mapView.frame.origin = CGPoint(x: -self.view.frame.width, y: 0)
            self.rightFriendsView.frame.origin = CGPoint(x: 0, y: 0)
        }) { (true) in
            
            self.view.bringSubviewToFront(self.bottomMenu_main)
            self.view.bringSubviewToFront(self.bottomMenu_map)
            self.view.bringSubviewToFront(self.bottomMenu_friends)
            
            self.bottomMenu_map.setImage(UIImage(named: "map.png"), for: UIControl.State.normal)
            self.bottomMenu_main.setImage(UIImage(named: "home.png"), for: UIControl.State.normal)
            self.bottomMenu_friends.setImage(UIImage(named: "100_friends.png"), for: UIControl.State.normal)

        }
        
        
    }
    
    @objc func changeImage(_ sender: Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func goFilter() {
        self.performSegue(withIdentifier: "mapToFilter", sender: self)
    }
    
    @objc func goSettings() {
        
        //window = UIWindow()
        //window?.makeKeyAndVisible()
        //window?.rootViewController = UINavigationController(rootViewController: SettingsViewController())
        self.performSegue(withIdentifier: "mapToSettings", sender: self)
    }
    
    @objc func logout() {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "mainToLogin", sender: self)
    }
    
    // MARK: - Helper
    
    func showTopTile(show:Bool, hide:Bool = false) {
        
        //        if hide {
        ////            self.bottomTile.alpha = 0.0
        //
        //            UIView.animate(withDuration: 0.2) {
        //                self.topTile.frame.origin = CGPoint(x: 20, y: -130)
        //            }
        //            topTileShowing = false
        //            return
        //        }
        if show {
            self.topTile.alpha = 1.0
            UIView.animate(withDuration: 0.2) {
                self.topTile.frame.origin = CGPoint(x: 20, y: 50)
            }
            topTileShowing = true
        } else {
            UIView.animate(withDuration: 0.2) {
                self.topTile.frame.origin = CGPoint(x: 20, y: -130)
            }
            topTileShowing = false
        }
        
    }
    
    
    func showBigTile(show:Bool) {
        
        if show {
            showTopTile(show: false, hide: true)
            
            UIView.animate(withDuration: 0.2) {
                self.bigTile.frame.origin = CGPoint(x: 20, y: self.view.frame.height/6)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.bigTile.frame.origin = CGPoint(x: 20, y: -self.view.frame.height)
            }
        }
        
    }
    
    func getHeatMapColor(numPeople: Int) -> String{
        
        switch numPeople {
        case 0:
            return heatmap_smallToBig[1]
            
        case 1..<5:
            return heatmap_smallToBig[2]
            
        case 5..<15:
            return heatmap_smallToBig[3]
            
        case 15..<30:
            return heatmap_smallToBig[4]
            
        case 30..<50:
            return heatmap_smallToBig[5]
            
        case 50..<100:
            return heatmap_smallToBig[6]
            
        default:
            return heatmap_smallToBig[7]
        }
        
    }
    
    func loadBottomTile() {
        let f = CGRect(x: 20, y: -130, width: self.view.frame.width-40, height: 130)
        topTile = UIView(frame: f)
        topTile.backgroundColor = UIColor.white
        topTile.layer.cornerRadius = 10
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bottomTileTap(sender:)))
        
        // 2. add the gesture recognizer to a view
        topTile.addGestureRecognizer(tapGesture)
        
        
        let f2 = CGRect(x: 10, y: 10, width: f.width-10, height: 20)
        bottom_titleLabel = UILabel(frame: f2)
        bottom_titleLabel.text = ""
        bottom_titleLabel.textColor =  UIColor.black
        bottom_titleLabel.textAlignment = .center
        
        let f3 = CGRect(x: 10, y: 40, width: f.width-10, height: 20)
        bottom_subtitleLabel = UILabel(frame:f3)
        bottom_subtitleLabel.text  = ""
        bottom_subtitleLabel.textColor =  UIColor.black
        
        let f4 = CGRect(x: 10, y: 80, width: f.width-10, height: 40)
        bottom_descriptionLabel = UILabel(frame:f4)
        bottom_descriptionLabel.text = ""
        bottom_descriptionLabel.textColor =  UIColor.black
        bottom_descriptionLabel.numberOfLines = 5
        bottom_descriptionLabel.font = UIFont.italicSystemFont(ofSize: 16.0)
        
        topTile.addSubview(bottom_titleLabel)
        topTile.addSubview(bottom_subtitleLabel)
        topTile.addSubview(bottom_descriptionLabel)
        
        self.mapView.addSubview(topTile)
        
        
    }
    
    
    func loadBigTile() {
        let f = CGRect(x: 20, y: -(2*self.view.frame.height/3), width: self.view.frame.width-40, height: 2*self.view.frame.height/3)
        bigTile = UIView(frame: f)
        bigTile.backgroundColor = UIColor.white
        bigTile.layer.cornerRadius = 10
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bigTileTap(sender:)))
        
        // 2. add the gesture recognizer to a view
        bigTile.addGestureRecognizer(tapGesture)
        
        
        let f2 = CGRect(x: 10, y: 10, width: f.width-10, height: 30)
        big_titleLabel = UILabel(frame: f2)
        big_titleLabel.text = ""
        big_titleLabel.textColor =  UIColor.black
        big_titleLabel.textAlignment = .center
        
        let f2_2 = CGRect(x: bigTile.frame.width-30, y: 15, width: 15, height: 15)
        big_exitButton = UIButton(frame: f2_2)
        big_exitButton.setTitle("X", for: UIControl.State.normal)
        big_exitButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        big_exitButton.addTarget(self, action: #selector(dismissBigTile), for: .touchUpInside)
        
        
        let f3 = CGRect(x: 10, y: 50, width: f.width-10, height: 30)
        big_subtitleLabel = UILabel(frame:f3)
        big_subtitleLabel.text  = ""
        big_subtitleLabel.textColor =  UIColor.black
        
        let f4 = CGRect(x: 10, y: 90, width: f.width-10, height: 50)
        big_descriptionLabel = UILabel(frame:f4)
        big_descriptionLabel.text = ""
        big_descriptionLabel.textColor =  UIColor.black
        big_descriptionLabel.numberOfLines = 5
        big_descriptionLabel.font = UIFont.italicSystemFont(ofSize: 16.0)
        
        let f4_2 = CGRect(x: 10, y: 150, width: f.width-10, height: 50)
        big_entranceLabel = UILabel(frame:f4_2)
        big_entranceLabel.text = ""
        big_entranceLabel.textColor =  UIColor.black
        big_entranceLabel.numberOfLines = 3
        
        let f5 = CGRect(x: 30, y: bigTile.frame.height - 70, width: 50, height: 50)
        let left_box = UIView(frame: f5)
        left_box.backgroundColor = hexStringToUIColor(hex: "#F66745")
        left_box.layer.cornerRadius = 10
        
        let f6 = CGRect(x: (bigTile.frame.width/2)-25, y: bigTile.frame.height - 70, width: 50, height: 50)
        let middle_box = UIView(frame: f6)
        middle_box.backgroundColor = hexStringToUIColor(hex: "#F66745")
        middle_box.layer.cornerRadius = 10
        
        let f7 = CGRect(x: bigTile.frame.width-80, y: bigTile.frame.height - 70, width: 50, height: 50)
        let right_box = UIView(frame: f7)
        right_box.backgroundColor = hexStringToUIColor(hex: "#F66745")
        right_box.layer.cornerRadius = 10
        
        let w = bigTile.frame.width - 50
        let f8 = CGRect(x: 25, y: 250, width: w, height: 2*w/3)
        let image_map = UIImageView(frame: f8)
        image_map.image = UIImage(named: "map_example.jpg")
        image_map.layer.cornerRadius = 10
        
        bigTile.addSubview(left_box)
        bigTile.addSubview(middle_box)
        bigTile.addSubview(right_box)
        bigTile.addSubview(image_map)
        
        bigTile.addSubview(big_titleLabel)
        bigTile.addSubview(big_exitButton)
        bigTile.addSubview(big_subtitleLabel)
        bigTile.addSubview(big_descriptionLabel)
        bigTile.addSubview(big_entranceLabel)
        
        self.mapView.addSubview(bigTile)
        
    }
    
    @objc func dismissBigTile(sender: UIButton!) {
        showBigTile(show: false)
    }
    
    @objc func bottomTileTap(sender: UITapGestureRecognizer) {
        
        big_titleLabel.text = bottom_titleLabel.text
        big_subtitleLabel.text = bottom_subtitleLabel.text
        big_descriptionLabel.text = bottom_descriptionLabel.text
        big_entranceLabel.text = "Entry details: up the stairs and to the right, flat 4. "
        
        showBigTile(show: true)
    }
    
    @objc func bigTileTap(sender: UITapGestureRecognizer) {
        
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func dot(size: Int, num:Int) -> UIImage {
        let floatSize = CGFloat(size)
        let rect = CGRect(x: 0, y: 0, width: floatSize, height: floatSize)
        let strokeWidth: CGFloat = 1
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        let ovalPath = UIBezierPath(ovalIn: rect.insetBy(dx: strokeWidth, dy: strokeWidth))
        hexStringToUIColor(hex: getHeatMapColor(numPeople: num)).setFill()
        ovalPath.fill()
        
        UIColor.white.setStroke()
        ovalPath.lineWidth = strokeWidth
        ovalPath.stroke()
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func distanceBetweenTwoCoordinates(loc1:CLLocationCoordinate2D, loc2: CLLocationCoordinate2D) -> Int  {
        // using the haversine formula
        
        let R = 6371000.0; // metres
        
        let lat1 = loc1.latitude * .pi / 180
        let lat2 = loc2.latitude * .pi / 180
        
        let lon1 = loc1.longitude * .pi / 180
        let lon2 = loc2.longitude * .pi / 180


        let deltaLat = lat1-lat2
        let deltaLon = lon1-lon2
        
        let a = sin(deltaLat/2) * sin(deltaLat/2) +
            cos(lat1) * cos(lat2) *
            sin(deltaLon/2) * sin(deltaLon/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let d = R * c;
        
        return Int(d)
    }

}



//  extensions to help with changing profile picture
extension InteractiveMap: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profile.image = pickedImage
            
            // For future: this code snippet is almost a copy of SignUp, better way to structure?
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            self.uploadProfileImage(pickedImage){ url in
                if url != nil {
                    //  Update photoURL onto Firebase Authentication
                    changeRequest?.photoURL = url
                    changeRequest?.commitChanges { error in
                        if error == nil {
                            print("User photoURL changed!")
                        } else {
                            print("Error: \(error!.localizedDescription)")
                        }
                    }
                } else {
                    // Error unable to upload profile image
                    print("Something went wrong when updating profile image")
                }
            }
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // For future: this code snippet is a copy of SignUp, better way to structure?
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        //  Retrive username and image info
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
}
