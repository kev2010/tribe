//
//  SettingsSection.swift
//  Xplore
//
//  Created by Kevin Jiang on 9/20/19.
//  Copyright © 2019 Kevin Jiang. All rights reserved.
//

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Social
    case Communications
    
    var description: String {
        switch self {
        case .Social: return "My Account"
        case .Communications: return "More Information"
        }
    }
}

enum SocialOptions: Int, CaseIterable, SectionType {
    case logout
    case privacy
    
    var containsSwitch: Bool { return false }
    
    var description: String {
        switch self {
        case .privacy: return "Privacy"
        case .logout: return "Log Out"
        }
    }
}

enum CommunicationOptions: Int, CaseIterable, SectionType {
//    case notifications
//    case email
//    case reportCrashes
//
//    var containsSwitch: Bool {
//        switch self {
//        case .notifications: return true
//        case .email: return true
//        case .reportCrashes: return true
//        }
//    }
//
//    var description: String {
//        switch self {
//        case .notifications: return "Notifications"
//        case .email: return "Email"
//        case .reportCrashes: return "Report Crashes"
//        }
//    }
    case contactus
    
    var containsSwitch: Bool { return false }
    
    var description: String {
        switch self {
        case .contactus: return "Contact Us"
        }
    }
}


