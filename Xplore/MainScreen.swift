//
//  MainScreen.swift
//  Xplore
//
//  Created by Kevin Jiang on 7/31/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

import UIKit
import Mapbox

class MainScreen: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    //  Controls the home and map screens
    @IBOutlet weak var pageView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Initialize two screens
        let homescreen : Home = Home(nibName: "Home", bundle: nil)
        let mapscreen : InteractiveMap = InteractiveMap(nibName: "InteractiveMap", bundle: nil)
        
        //  Adding home screen
        self.addChild(homescreen)
        self.pageView.addSubview(homescreen.view)
        homescreen.didMove(toParent: self)
        //  Adding map screen
        self.addChild(mapscreen)
        self.pageView.addSubview(mapscreen.view)
        mapscreen.didMove(toParent: self)
        
        //  Creating "scrolling" feature for the screens
        var mapFrame : CGRect = mapscreen.view.frame
        mapFrame.origin.x = self.view.frame.width
        mapscreen.view.frame = mapFrame
        self.pageView.contentSize = CGSize(width: self.view.frame.width*2, height: self.view.frame.height)
        
    }
    

}

