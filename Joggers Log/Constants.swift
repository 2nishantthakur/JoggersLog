//
//  Constants.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 31/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import Foundation

struct Constants {
    struct signUpMethods{
        static let facebook = "Facebook"
        static let google = "Google"
    }
    struct segues{
        static let SignUpDetailsViewController  = "SignUpDetailsViewController"
        static let ShowLoggedInScreen = "ShowLoggedInScreen"
        static let successfullLogin = "successfullLogin"
    }
    struct VC {
        static let LoginViewController = "LoginViewController"
        static let LoggedInViewController = "LoggedInViewController"
        static let SignUpViewController = "SignUpViewController"
        static let FirstScreen = "ViewController"
    }
    struct entity{
        static let LoggedInUser = "LoggedInUser"
    }
    struct attributes{
        static let email = "email"
        static let name = "name"
    }
}
