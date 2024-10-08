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

var bookmarks:[Bookmark] = []
var bookmarksTable = UITableView()
var friendtable = UITableView()

class InteractiveMap: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MGLMapViewDelegate, CLLocationManagerDelegate{
    let info = DispatchGroup()
    let manager = CLLocationManager()
    let db = Firestore.firestore()
    
    var currentLocation = CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
    var previousLocation = CLLocationCoordinate2D.init(latitude: 0.1, longitude: 0.1)
    
    //  Used for Settings Screen
    var window: UIWindow?
    
    var displayed_events : [String:Event] = [:]
    var current_annotation : Event?
    
    //    var allEventsSearch : [[Event]] = [[]]
    var annotationsForID : [String: CustomPointAnnotation] = [:]
    
    //  Used for Home Screen
    
    //  Used for Friends Screen
    var refreshControl = UIRefreshControl()
    var friends:[Friend] = []
    var filteredfriends:[Friend] = []
    var friendsearch = UISearchBar()
    
    var event_points = [MGLAnnotation]()
    var all_events : [(Event, Bool)] = []
    
    var current_friends : [CustomPointAnnotation] = []
    
    var totalShift = 0.0
    
    //  Used for Interactive Map Screen
    var timer = Timer()
    var searchEvent = UISearchBar()
    
    //  Bottom tile variables - global
    var topTileShowing = false
    var topTile = UIView()
    var top_title_label = UILabel()
    var top_subtitle_label = UILabel()
    var top_subtitle_label_2 = UILabel()

    
    //  Big tile variablees - global
    var bigTile = UIView()
    var big_titleLabel = UILabel()
    var big_subtitleLabel = UILabel()
    var big_entranceLabel  = UILabel()
    var big_descriptionLabel = UILabel()
    var big_exitButton = UIButton()
    
    var leftMenuView = UIView()
    var mapView = MGLMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var rightFriendsView = UIView()
    
    var bottomMenu_main = UIButton()
    var bottomMenu_map = UIButton()
    var bottomMenu_friends = UIButton()
    
    var imagePicker = UIImagePickerController()
    var profile = UIImageView()
    
    var firstTimeLocation = true
    
    var filterApp = [1, 1, 1, 1, 1, 1];
    
    enum screen {
        case Main
        case Map
        case Friends
    }
    
    var currentScreen = screen.Map
    
    @IBAction func toHome(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toMain", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Create the home, map, and friends screens
        self.createThreeViewUI()
        
        //  Set Up relevant Friends data for Interactive Map and Friends Screen
        FriendsAPI.getFriends() // model
        filteredfriends = friends
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: Notification.Name("didDownloadFriends"), object: nil)
        
        //  Load Events onto the map
        loadAndAddEvents()
        
        //  Configure location manager to user's location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        loadTopTile()
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
        
        //  TODO: Create a timer that refreshes friends and bookmarks every 1 minute
        
        
    }
    
    func updateFilters(new_filters:[Int]) {
        self.filterApp = new_filters
        mapView.removeAnnotations(event_points)
        var temp : [(Event, Bool)] = []
        
        for elem in all_events {
            temp.append((elem.0, elem.1))
        }
        
        all_events = []
        addEventsToMap(events: temp)
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        if let data = notification.object as? [Friend]
        {
            mapView.removeAnnotations(current_friends)
            current_friends = []
            //  Update friend variables
            friends = data
            filteredfriends = friends
            
            //  Update Friends Screen
            friendtable.reloadData()
            //  Update Map Screen
            addFriendsToMap()
        }
        
        if let data = notification.object as? [Bookmark]
        {
            bookmarks = data
            bookmarksTable.reloadData()
        }
    }
    
    
    func loadAndAddEvents(){
        var allEvents : [(Event, Bool)] = []
        let bookmarked = currentUser?.eventsUserBookmarked
        
        db.collection("events").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let e = Event(QueryDocumentSnapshot: document)
                    
                    let documentRefString = self.db.collection("events").document(e.documentID!)
                    let userRef = self.db.document(documentRefString.path)
                    let b = bookmarked?.contains(userRef)
                    allEvents.append((e,b!))
                }
                
                self.addEventsToMap(events: allEvents)
            }
        }
    }
    
    func addEventsToMap(events:[(Event, Bool)]) {
        all_events += events
        // Fill an array with point annotations and add it to the map.
        var pointAnnotations = [CustomPointAnnotation]()
        for (event, bookmarked) in events {
            if event.startDate > Date() || (event.startDate < Date() && event.endDate > Date()) {
                let filtered = event.tags.contains("Academic") && filterApp[0]==1 ||
                    event.tags.contains("Arts") && filterApp[1]==1 ||
                    event.tags.contains("Athletic") && filterApp[2]==1 ||
                    event.tags.contains("Casual") && filterApp[3]==1 ||
                    event.tags.contains("Professional") && filterApp[4]==1 ||
                    event.tags.contains("Social") && filterApp[5]==1;
                if (filtered) {
                    displayed_events[event.documentID!] = event
                    let point = CustomPointAnnotation(coordinate: event.location, title: event.title, subtitle: "\(event.capacity) people", description: event.description, annotationType: AnnotationType.Event, event_id: event.documentID, bm: bookmarked, event: event)
                    point.reuseIdentifier = "customAnnotation\(event.title)"
                    point.image = InteractiveMap.dot(size: 30, num: event.capacity, bm: bookmarked)
                    
                    self.annotationsForID[event.documentID!] = point
                    
                    pointAnnotations.append(point)
                    
                    if bookmarked {
                        bookmarks.append(Bookmark(event: event, annotation: point))
                        bookmarksTable.reloadData()
                    }
                }
            }
        }
        
        mapView.addAnnotations(pointAnnotations)
        event_points = pointAnnotations
    }
    
    func addFriendsToMap(){
        //  Create an annotation for each friend
        var pointAnnotations = [CustomPointAnnotation]()
        for i in 0...friends.count-1 {
            if friends[i].user?.privacy != "Private" {
                let annotation = CustomPointAnnotation(coordinate: friends[i].user!.currentLocation, title: friends[i].user?.name, subtitle: "", description: "", annotationType: AnnotationType.User, event_id: friends[i].user!.documentID, bm:false, event: nil)
                annotation.reuseIdentifier = "customAnnotationFriend\(String(describing: friends[i].user?.username))"
                annotation.image = friends[i].picture!.scaleImage(toSize: CGSize(width: 10, height: 10))?.circleMasked
                //                annotation.image = dot(size: 25, num: 5)
                pointAnnotations.append(annotation)
                friends[i].annotation = annotation
            }
        }
        
        current_friends += pointAnnotations
        mapView.addAnnotations(pointAnnotations)
    }
    
    
    // MARK: - Create UI
    
    func createThreeViewUI() {
        self.createLeftMenu()
        self.createMiddleMap()
        self.createRightFriends()
    }
    
    
    func createLeftMenu() {

        //  Create the background
        let f = CGRect(x: -self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        //        let f = CGRect(x: -self.view.frame.width, y: self.view.frame.height/2, width: 400, height: 400)
        leftMenuView = UIView(frame: f)
        
        //  Add Profile Title
        let profileHeader = UILabel()
        profileHeader.text = "PROFILE"
        profileHeader.frame = CGRect(x: 0, y: leftMenuView.frame.height/14, width: leftMenuView.frame.width, height: 49)
        profileHeader.textAlignment = .center
        profileHeader.font = UIFont(name: "Futura-Bold", size: 24)
        profileHeader.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        leftMenuView.addSubview(profileHeader)

        //  Add settings button
        let settings_button = UIButton(type: UIButton.ButtonType.custom)
        settings_button.frame = CGRect(x: 19, y: 45, width: 48, height: 48)
        settings_button.setImage(UIImage(named: "settings"), for: .normal)
        settings_button.addTarget(self, action: #selector(self.goSettings), for: UIControl.Event.touchDown)
        leftMenuView.addSubview(settings_button)
        
        //  Retrieve profile picture from Firebase Storage
        let ppRef = Storage.storage().reference(withPath: "users_profilepic/\(Auth.auth().currentUser!.uid)")
        ppRef.getData(maxSize: 1 * 512 * 512) { data, error in    // Might need to change size?
            if let error = error {
                print("Error in retrieving image: \(error.localizedDescription)")
            } else {
                let image = UIImage(data: data!)
                self.profile.image = image
            }
        }
        //  Add specifics to picture
        profile.frame = CGRect(x: 133, y: 140, width: 148, height: 148)
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
        leftMenuView.addSubview(profile)
        
        //  Add Name under profile picture
        let namelabel = UILabel(frame: CGRect(x: 0, y: 298, width: 414, height: 23))
        namelabel.text = currentUser!.username
        namelabel.textAlignment = .center
        namelabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        namelabel.font = UIFont(name: "Futura-Bold", size: 18)
        leftMenuView.addSubview(namelabel)
        
        //  Add Username under Name
        let usernamelabel = UILabel(frame: CGRect(x: 0, y: 318, width: 414, height: 23))
        usernamelabel.text = Auth.auth().currentUser!.displayName
        usernamelabel.textAlignment = .center
        usernamelabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        usernamelabel.font = UIFont(name: "Futura-Bold", size: 14)
        leftMenuView.addSubview(usernamelabel)
        
        //  Add "Bookmarks" title
        let bookmark_label = UILabel(frame: CGRect(x: 0, y: 353, width: leftMenuView.frame.width, height: 23))
        bookmark_label.text = "Bookmarks"
        bookmark_label.textAlignment = .center
        bookmark_label.textColor = UIColor(red: 0, green: 255/255, blue: 194/255, alpha: 1)
        bookmark_label.font = UIFont(name: "Futura-Bold", size: 18)
        leftMenuView.addSubview(bookmark_label)

        
        //  Add horizontal separators
        let bookmark_sep = UIView()
        bookmark_sep.backgroundColor = UIColor(red: 0, green: 255/255, blue: 194/255, alpha: 1)
        bookmark_sep.frame = CGRect(x: 0, y: 378, width: leftMenuView.frame.width, height: 3)
        leftMenuView.addSubview(bookmark_sep)
        
        //  Add bookmarked events UITableView
        bookmarksTable.dataSource = self
        bookmarksTable.delegate = self
        bookmarksTable.register(BookmarkCell.self, forCellReuseIdentifier: "bookmarkCell")
        leftMenuView.addSubview(bookmarksTable)
        bookmarksTable.frame = CGRect(x: 55, y: 380, width: leftMenuView.frame.width-110, height: 2*leftMenuView.frame.height/5+10)  //  Need to change frame later\
        bookmarksTable.backgroundColor = .clear
        bookmarksTable.separatorStyle = .none
        bookmarksTable.tableFooterView = UIView()
        //  TODO: Sort by start date? - Might want to customize sorting in the future

        self.view.addSubview(leftMenuView)
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanLeft))
        leftMenuView.addGestureRecognizer(gestureRecognizer)
        
        
    }
    
    func createMiddleMap() {
        //Load map view
        mapView = MGLMapView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        //        mapView.styleURL = URL(string: "mapbox://styles/kev2018/cjytf3psp05u71cqm0l0bacgt")
        //        mapView.styleURL = URL(string: "mapbox://styles/kev2018/cjytijoug092v1cqz0ogvzb0w")
        mapView.styleURL = URL(string: "mapbox://styles/kev2018/ck6n11yek073u1ilaz46m0706")
        mapView.delegate = self
        
        //Add map and button to scroll view
        self.view.addSubview(mapView)
        
        let f2 = CGRect(x: self.view.frame.width/2-140, y: 5*self.view.frame.height/6, width: 70, height: 70)
        bottomMenu_main = UIButton(frame: f2)
        bottomMenu_main.addTarget(self, action: #selector(self.goMain), for: UIControl.Event.touchDown)
        bottomMenu_main.setImage(UIImage(named: "homeoff"), for: UIControl.State.normal)
        
        let f3 = CGRect(x: self.view.frame.width/2-35, y: 5*self.view.frame.height/6, width: 70, height: 70)
        bottomMenu_map = UIButton(frame: f3)
        bottomMenu_map.addTarget(self, action: #selector(self.goMap), for: UIControl.Event.touchDown)
        bottomMenu_map.setImage(UIImage(named: "addon"), for: UIControl.State.normal)
        
        let f4 = CGRect(x: self.view.frame.width/2+70, y: 5*self.view.frame.height/6, width: 70, height: 70)
        bottomMenu_friends = UIButton(frame: f4)
        bottomMenu_friends.addTarget(self, action: #selector(self.goFriends), for: UIControl.Event.touchDown)
        bottomMenu_friends.setImage(UIImage(named: "friendsoff"), for: UIControl.State.normal)
        
        
        self.view.addSubview(bottomMenu_main)
        self.view.addSubview(bottomMenu_map)
        self.view.addSubview(bottomMenu_friends)
        
        self.view.bringSubviewToFront(bottomMenu_main)
        self.view.bringSubviewToFront(bottomMenu_map)
        self.view.bringSubviewToFront(bottomMenu_friends)
        
        let f5 = CGRect(x: 2*self.view.frame.width/3, y: 50, width: 125, height: 125)
        let filter_button = UIButton(frame: f5)
        filter_button.setImage(UIImage(named: "filter"), for: .normal)
        filter_button.imageView?.contentMode = .scaleAspectFit
        filter_button.addTarget(self, action: #selector(self.goFilter), for: UIControl.Event.touchDown)
        
        mapView.addSubview(filter_button)
        
        let f6 = CGRect(x: 19, y: 50, width: 125, height: 125)
        let search_button = UIButton(frame: f6)
        search_button.setImage(UIImage(named: "search"), for: .normal)
        search_button.imageView?.contentMode = .scaleAspectFit
        search_button.addTarget(self, action: #selector(self.goSearch), for: UIControl.Event.touchDown)
        
        mapView.addSubview(search_button)
        
        self.searchEvent.delegate = self
        self.searchEvent.frame = CGRect(x: 20, y: 60, width: 375, height: 50)
        self.searchEvent.placeholder = "Search"
//        self.searchEvent.searchBarStyle = .minimal
        self.searchEvent.backgroundColor = .white
        self.searchEvent.alpha = 1.0
    
        (self.searchEvent.value(forKey: "searchField") as! UITextField).alpha = 1.0
        (self.searchEvent.value(forKey: "searchField") as! UITextField).backgroundColor = .white
        (self.searchEvent.value(forKey: "searchField") as! UITextField).tintColor = .white
        // SearchBar text
        let textFieldInsideUISearchBar = self.searchEvent.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont.init(name: "Futura-Bold", size: 16)

        // SearchBar placeholder
        let textFieldInsideUISearchBarLabel = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideUISearchBarLabel?.font = UIFont.init(name: "Futura-Bold", size: 16)
        

        
//        mapView.addSubview(searchEvent)
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar == searchEvent {
//            self.present(UINavigationController(rootViewController: SearchViewController()), animated: false, completion: nil)
            UIView.setAnimationsEnabled(false)
            self.performSegue(withIdentifier: "mapToSearch", sender: self)
            UIView.setAnimationsEnabled(true)
            
        }
    }
    
    func createRightFriends() {
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        friendtable.addSubview(refreshControl) // not required when using UITableViewController
        
        //  Set up rightFriendsView
        let f = CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        rightFriendsView = UIView(frame: f)
        //        let color1 = UIColor(displayP3Red: 0/255, green: 230/255, blue: 179/255, alpha: 1)
        //        let color2 = UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
        rightFriendsView.backgroundColor = .white
        
        //  Add Friends screen title
        let friendsHeader = UILabel()
        friendsHeader.text = "FRIENDS"
        friendsHeader.frame = CGRect(x: 0, y: rightFriendsView.frame.height/14, width: rightFriendsView.frame.width, height: 49)
        friendsHeader.textAlignment = .center
        friendsHeader.font = UIFont(name: "Futura-Bold", size: 24)
        friendsHeader.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        rightFriendsView.addSubview(friendsHeader)
        
        //        //  Add horizontal separator
        //        let separator = UIView()
        //        separator.backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 235/255, alpha: 1)
        //        separator.frame = CGRect(x: 0, y: rightFriendsView.frame.height/8, width: rightFriendsView.frame.width, height: 4)
        //        rightFriendsView.addSubview(separator)
        
        //  Add add friend button
        let add = UIButton()
        add.frame = CGRect(x: 4*rightFriendsView.frame.width/5, y: rightFriendsView.frame.height/14, width: rightFriendsView.frame.width/4, height: 49)
        add.addTarget(self, action: #selector(self.addFriend), for: UIControl.Event.touchDown)
        add.setTitle("+", for: UIControl.State.normal)
        add.setTitleColor(UIColor(red: 0, green: 255/255, blue: 194/255, alpha: 1), for: UIControl.State.normal)
        add.titleLabel!.font = UIFont(name: "Futura-Bold", size: 36)
        rightFriendsView.addSubview(add)
        
        
        //  Set up friend uitable
        friendtable.dataSource = self
        friendtable.delegate = self
        friendtable.register(FriendsCell.self, forCellReuseIdentifier: "friendCell")
        rightFriendsView.addSubview(friendtable)
        friendtable.frame = CGRect(x: 0, y: rightFriendsView.frame.height/5, width: rightFriendsView.frame.width, height: rightFriendsView.frame.height*(4/5))
        friendtable.separatorStyle = .none
        friendtable.tableFooterView = UIView()
        
        //  Set up search bar
        friendsearch.delegate = self
        friendsearch.frame = CGRect(x: 0, y: rightFriendsView.frame.height/5-friendsearch.frame.height-55, width: rightFriendsView.frame.width, height: 56)
        friendsearch.backgroundColor = .white
        friendsearch.placeholder = "Search"
        friendsearch.searchBarStyle = .minimal
        // SearchBar text
        let textFieldInsideUISearchBar = friendsearch.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont.init(name: "Futura-Bold", size: 16)
        
        // SearchBar placeholder
        let textFieldInsideUISearchBarLabel = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideUISearchBarLabel?.font = UIFont.init(name: "Futura-Bold", size: 16)
        rightFriendsView.addSubview(friendsearch)
        
        self.view.addSubview(rightFriendsView)
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanRight))
        rightFriendsView.addGestureRecognizer(gestureRecognizer)
    }
    
    //  protocol methods for Friends and BookmarkedEvents Tables
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == bookmarksTable {
            return bookmarks.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == friendtable {
            return filteredfriends.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == bookmarksTable {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //  Will need to adjust values later
        if tableView == friendtable {
            return 100
        } else if tableView == bookmarksTable {
            return 80
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == bookmarksTable {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.clear
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == friendtable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsCell
            cell.friend = filteredfriends[indexPath.row]
            friendtable.bringSubviewToFront(cell)
            view.bringSubviewToFront(friendtable)
            return cell
        } else if tableView == bookmarksTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath) as! BookmarkCell
            cell.bookmark = bookmarks[indexPath.section]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            let color1 = UIColor(red: 146/255, green: 191/255, blue: 230/255, alpha: 1)
            let color2 = UIColor(red: 49/255, green: 255/255, blue: 255/255, alpha: 1)
            cell.addGradientLayer(topColor: color1, bottomColor: color2, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 0))
            //            cell.clipsToBounds = true
            //            cell.layer.cornerRadius = 15
            //            let shadowPath2 = UIBezierPath(rect: cell.bounds)
            //            cell.layer.masksToBounds = false
            //            cell.layer.shadowColor = UIColor(red: 70/255, green: 181/255, blue: 231/255, alpha: 1).cgColor
            //            cell.layer.shadowOffset = CGSize(width: CGFloat(1.0), height: CGFloat(3.0))
            //            cell.layer.shadowOpacity = 1
            //            cell.layer.shadowPath = shadowPath2.cgPath
            
            //            cell.backgroundColor = UIColor(red: 70/255, green: 181/255, blue: 231/255, alpha: 1)
            //            let color1 = UIColor(red: 146/255, green: 191/255, blue: 230/255, alpha: 1)
            //            let color2 = UIColor(red: 49/255, green: 255/255, blue: 255/255, alpha: 1)
            //            cell.addGradientLayer(topColor: color1, bottomColor: color2, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 0))
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 25
            cell.layer.masksToBounds = true
            //            cell.backgroundColor = UIColor(displayP3Red: 0/255, green: 182/255, blue: 255/255, alpha: 1)
            bookmarksTable.bringSubviewToFront(cell)
            view.bringSubviewToFront(bookmarksTable)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == friendtable {
            if editingStyle == .delete {
                let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove this friend?", preferredStyle: .alert)

                let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    self.removeFriend(friend: self.filteredfriends[indexPath.row])
                    self.filteredfriends.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                })
                alertController.addAction(deleteAction)

                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)

                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func removeFriend(friend : Friend) {
        let presentUser = currentUser!.username
        let deletedUser = friend.user!.username
        
        let db = Firestore.firestore()
        let presentUserDocumentRefString = db.collection("users").document(presentUser)
        let presentUserRef = db.document(presentUserDocumentRefString.path)
        let deletedUserDocumentRefString = db.collection("users").document(deletedUser)
        let deletedUserRef = db.document(deletedUserDocumentRefString.path)
        
        //  Remove deleted user from current user's friends list
        Firestore.firestore().collection("users").document(presentUser).updateData([
            "social.friends": FieldValue.arrayRemove([deletedUserRef])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        //  Remove current user from deleted user's friends list
        Firestore.firestore().collection("users").document(deletedUser).updateData([
            "social.friends": FieldValue.arrayRemove([presentUserRef])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == friendtable {
            self.searchBarCancelButtonClicked(friendsearch)
            self.goMap()
            self.mapView.selectAnnotation(filteredfriends[indexPath.row].annotation!, animated: true) {
                
                let a : CustomPointAnnotation = self.filteredfriends[indexPath.row].annotation! as! CustomPointAnnotation
                let botleft = CLLocationCoordinate2D(latitude: a.coordinate.latitude - 0.01, longitude: a.coordinate.longitude - 0.01)
                let topright = CLLocationCoordinate2D(latitude: a.coordinate.latitude + 0.01, longitude: a.coordinate.longitude + 0.01)
                let region:MGLCoordinateBounds = MGLCoordinateBounds(sw: botleft, ne: topright)
                
                self.mapView.setVisibleCoordinateBounds(region, animated: true)
                
            }
        } else if tableView == bookmarksTable {
            self.goMap()
            self.mapView.selectAnnotation(bookmarks[indexPath.section].annotation!, animated: true) {
                let a : MGLAnnotation = bookmarks[indexPath.row].annotation!
                let botleft = CLLocationCoordinate2D(latitude: a.coordinate.latitude - 0.01, longitude: a.coordinate.longitude - 0.01)
                let topright = CLLocationCoordinate2D(latitude: a.coordinate.latitude + 0.01, longitude: a.coordinate.longitude + 0.01)
                let region:MGLCoordinateBounds = MGLCoordinateBounds(sw: botleft, ne: topright)
                
                self.mapView.setVisibleCoordinateBounds(region, animated: true)
            }
            
            
            
            bookmarksTable.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //  If there is no text, filteredfriends is the same as original friends
        filteredfriends = searchText.isEmpty ? friends : friends.filter { (item: Friend) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.user?.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        friendtable.reloadData()
    }
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        friendsearch.showsCancelButton = true
//    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        friendsearch.showsCancelButton = false
        friendsearch.text = ""
        friendsearch.resignFirstResponder()
        friendsearch.endEditing(true)
        filteredfriends = friends   // Is there a way to not do this?
        friendtable.reloadData()
    }
    
    @objc func addFriend(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                sender.transform = CGAffineTransform.identity
                            })
        })
        
        self.performSegue(withIdentifier: "friendsToAdd", sender: self)
    }
    
    @objc func handlePanLeft(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            
            let translation = gestureRecognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            
            if translation.x < 0 {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y)
                mapView.center = CGPoint(x: mapView.center.x + translation.x, y: mapView.center.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
                totalShift += Double(translation.x)
            }
            else if totalShift<0{
                let new_x = gestureRecognizer.view!.center.x + translation.x
                gestureRecognizer.view!.center = CGPoint(x: new_x, y: gestureRecognizer.view!.center.y)
                mapView.center = CGPoint(x: mapView.center.x + translation.x, y: mapView.center.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
            
            
        }
            
        else if gestureRecognizer.state == .ended {
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
            
            if mapView.center.x > 0 {
                goMap()
            }
            else {
                goFriends()
            }
        }
    }
    
    @objc func refresh(sender:AnyObject) {
        FriendsAPI.getFriends()
        refreshControl.endRefreshing()
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
        
        if let a = annotation as? CustomPointAnnotation{
            if  a.type == .Event {
                if let point = annotation as? CustomPointAnnotation {
                    current_annotation = displayed_events[point.event_id!]
                    if topTileShowing {
                        top_title_label.text = point.title!
                        let format = DateFormatter()
                        format.dateFormat = "MM/dd/yyyy HH:mm"
                        let formattedDate1 = format.string(from: a.event!.startDate)
                        let formattedDate2 = format.string(from: a.event!.endDate)
                        
                        top_subtitle_label.text  = "FROM \(formattedDate1)"
                        top_subtitle_label_2.text = "TO \(formattedDate2)"
                    }
                    else {
                        
                        top_title_label.text = point.title!
                        let format = DateFormatter()
                        format.dateFormat = "MM/dd/yyyy HH:mm"
                        let formattedDate1 = format.string(from: a.event!.startDate)
                        let formattedDate2 = format.string(from: a.event!.endDate)
                        
                        top_subtitle_label.text  = "FROM \(formattedDate1)"
                        top_subtitle_label_2.text = "TO \(formattedDate2)"
                        showTopTile(show: true)
                        topTileShowing = true
                    }
                }
            }
        }
        
    }
    
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        if topTileShowing {
            showTopTile(show: false)
            topTileShowing = false
        }
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        
        OperationQueue.main.addOperation
            {() -> Void in
                //TODO
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
        if (firstTimeLocation) {
            mapView.setVisibleCoordinateBounds(region, animated: false)
            firstTimeLocation = false
        }
        mapView.showsUserLocation = true
        
        
        currentLocation = location.coordinate
    }
    
    @objc func refreshData() {
        //  Refresh Location Data
        if !(currentLocation.latitude == previousLocation.latitude && currentLocation.longitude == previousLocation.longitude){
            
            previousLocation = currentLocation
            
            if currentUser != nil {
                
                currentUser!.currentLocation = currentLocation
                currentUser!.updateUser()
                
            }
        }
        
        //  Refresh Table Data
        friendtable.reloadData()
        bookmarksTable.reloadData()
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
            
            self.bottomMenu_map.setImage(UIImage(named: "mapoff"), for: UIControl.State.normal)
            self.bottomMenu_main.setImage(UIImage(named: "homeon"), for: UIControl.State.normal)
            self.bottomMenu_friends.setImage(UIImage(named: "friendsoff"), for: UIControl.State.normal)
            
        }
    }
    
    
    func showExtraButtons() {
        //do animations to show add event and filter buttons
        UIView.animate(withDuration: 0.2) {
            
        }
        self.performSegue(withIdentifier: "mapToAddEvent", sender: self)
    }
    
    @objc func goMap() {
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
            
            self.bottomMenu_map.setImage(UIImage(named: "addon"), for: UIControl.State.normal)
            self.bottomMenu_main.setImage(UIImage(named: "homeoff"), for: UIControl.State.normal)
            self.bottomMenu_friends.setImage(UIImage(named: "friendsoff"), for: UIControl.State.normal)
            
            
            
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
            
            self.bottomMenu_map.setImage(UIImage(named: "mapoff"), for: UIControl.State.normal)
            self.bottomMenu_main.setImage(UIImage(named: "homeoff"), for: UIControl.State.normal)
            self.bottomMenu_friends.setImage(UIImage(named: "friendson"), for: UIControl.State.normal)
        }
    }
    
    @objc func changeImage(_ sender: Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func goFilter() {
        self.performSegue(withIdentifier: "mapToFilter", sender: self)
    }
    
    @objc func goSearch() {
        self.performSegue(withIdentifier: "mapToSearch", sender: self)
    }
    
    @objc func goSettings() {
        self.performSegue(withIdentifier: "mapToSettings", sender: self)
    }
    
    @objc func logout() {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "mainToLogin", sender: self)
    }
    
    // MARK: - Helper
    
    func showTopTile(show:Bool) {
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
    
    
    func showBigTile() {
        self.performSegue(withIdentifier: "toBigTile", sender: self)
    }
    
    static func getHeatMapColor(numPeople: Int) -> String{
        
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
            
        default:
            return heatmap_smallToBig[6]
            
        }
        
    }
    
    func loadTopTile() {
        let f = CGRect(x: 20, y: -130, width: self.view.frame.width-40, height: 130)
        topTile = UIView(frame: f)
        topTile.backgroundColor = UIColor(red:0, green:1, blue:0.761, alpha:1)
        topTile.layer.cornerRadius = 10
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(topTileTap(sender:)))
        
        // 2. add the gesture recognizer to a view
        topTile.addGestureRecognizer(tapGesture)
        
        
        let f2 = CGRect(x: 10, y: 10, width: f.width-10, height: 30)
        top_title_label = UILabel(frame: f2)
        top_title_label.text = ""
        top_title_label.font = UIFont(name: "Futura-Bold", size: 25)
        top_title_label.textColor =  UIColor.white
        top_title_label.textAlignment = .center
        
        let f3 = CGRect(x: 10, y: 60, width: f.width-10, height: 20)
        top_subtitle_label = UILabel(frame:f3)
        top_subtitle_label.text  = ""
        top_subtitle_label.font = UIFont(name: "Futura-Bold", size: 20)
        top_subtitle_label.textColor =  UIColor.white
        top_subtitle_label.textAlignment = .center
        
        let f4 = CGRect(x: 10, y: 90, width: f.width-10, height: 20)
        top_subtitle_label_2 = UILabel(frame:f4)
        top_subtitle_label_2.text  = ""
        top_subtitle_label_2.font = UIFont(name: "Futura-Bold", size: 20)
        top_subtitle_label_2.textColor =  UIColor.white
        top_subtitle_label_2.textAlignment = .center
        
//        let f4 = CGRect(x: 10, y: 80, width: f.width-10, height: 40)
//        top_description_label = UILabel(frame:f4)
//        top_description_label.text = ""
//        top_description_label.textColor =  UIColor.black
//        top_description_label.numberOfLines = 5
     //   bottom_descriptionLabel.font = "Comic Sans"; UIFont.italicSystemFont(ofSize: 16.0)
        
        topTile.addSubview(top_title_label)
        topTile.addSubview(top_subtitle_label)
        topTile.addSubview(top_subtitle_label_2)
//        topTile.addSubview(top_description_label)
        
        self.mapView.addSubview(topTile)
        
    }
    
    
    @objc func topTileTap(sender: UITapGestureRecognizer) {
        showBigTile()
    }

    static func hexStringToUIColor (hex:String) -> UIColor {
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
    
    static func dot(size: Int, num:Int, bm:Bool) -> UIImage {
        var floatSize = CGFloat(size)
        if bm {
            floatSize *= 1.2
        }
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toBigTile" {
            let vc = segue.destination as! BigTileViewController
            vc.event = current_annotation
            
        }
        
        if segue.identifier == "mapToFilter" {
            let vc = segue.destination as! FilterViewController
            vc.filterInfo = self.filterApp
        }
        
        if segue.identifier == "mapToFilter" {
            let vc = segue.destination as! FilterViewController
            vc.filterInfo = self.filterApp
        }
        
        if segue.identifier == "mapToSearch" {
            let vc = segue.destination as! SearchViewController
            vc.filterInfo = self.filterApp
        }
    }
}
