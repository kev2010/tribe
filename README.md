# tribe
tribe is an interactive map-based mobile application that connects users to nearby user-hosted events

## Requirements
There are three third-party packages that we are using to run the code: CocoaPods, Firebase, and MapBox.

### CocoaPods
CocoaPods lets you install dependencies into the project in the form of pod files. We will use this to download different packages into our code. 

### Firebase
Firebase is what we'll use for user login and security for now. Firebase automatically creates and tracks user login information in an online databse that I can access. 

### MapBox
MapBox let's us create custom-made maps with neat designs. We will be using this to power the interactive map in the app.


## Installation
To install these dependencies, first download CocoaPods (https://cocoapods.org/) by running the sudo code on the website. This should give you everything you need to access the pod files. In the terminal, change the working directory to the Xplore project and run `pod install`. Now, you should have everything that you need to access the project. To edit the code, it is **important** that you use `Xplore.xcworkspace` instead of `Xplore.xcodeproj`. 

## Troubleshooting
If the code displays an error like `Could not build Objective-C module 'Firebase'`, try reinstalling the pod files. Open the Xplore folder and delete `Xplore.xcworkspace`, `Podfile.lock`, and the `Pods` folder. In the terminal, run `pod install` in the directory of the Xplore project. If you run into any more problems, please message me and try Google!
