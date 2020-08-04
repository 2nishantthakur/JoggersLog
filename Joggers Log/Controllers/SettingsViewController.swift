//
//  SettingsViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 01/08/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logOut(_ sender: Any) {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        let loginManager = LoginManager()
        loginManager.logOut()
        GIDSignIn.sharedInstance().signOut()
        let rootViewController = storyboard!.instantiateViewController(withIdentifier: Constants.VC.FirstScreen)
        let nav = UINavigationController(rootViewController: rootViewController)
        self.view.window!.rootViewController = nav
        navigationController?.popToRootViewController(animated: true)
        //self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
