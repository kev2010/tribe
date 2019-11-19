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
    case privacy
    case logout
    
        var containsSwitch: Bool { return false }
    
//    var containsSwitch: Bool {
//        switch self {
//        case .privacy:
//            return true
//        default:
//            return false
//        }
//    }
    
    var description: String {
        switch self {
//        case .privacy: return "Hide Location"
        case .privacy: return "Privacy"
        case .logout: return "Log Out"
        }
    }
}

enum CommunicationOptions: Int, CaseIterable, SectionType {
    case tos
    case contactus
    
    var containsSwitch: Bool { return false }
    
    var description: String {
        switch self {
        case .tos: return "Terms of Service"
        case .contactus: return "Contact Us!"
        }
    }
}


