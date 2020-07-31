//
//  SignUpViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 26/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class SignUpViewController: UIViewController, GIDSignInDelegate {
    
    

   
    @IBOutlet var SwitchToLogin: UIButton!
    @IBOutlet var continueWithGoogle: GIDSignInButton!
    @IBOutlet var continueWithFacebook: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setButtonProperties()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self

        GIDSignIn.sharedInstance().signOut()
        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        //GIDSignIn.sharedInstance().uiDelegate = self
        
       
    }
    func setButtonProperties(){
        continueWithGoogle.layer.cornerRadius = continueWithGoogle.frame.height/2
        continueWithGoogle.layer.borderWidth = 2
        continueWithGoogle.layer.borderColor = UIColor.gray.cgColor
        //continueWithGoogle.imageView?.contentMode = .scaleAspectFit
        continueWithFacebook.layer.cornerRadius = continueWithFacebook.frame.height/2
        SwitchToLogin.underline()
    }
    //MARK:- signup with facebook
    @IBAction func signUpWithFacebook(_ sender: UIButton) {
        // 1
        let loginManager = LoginManager()
        
        if let _ = AccessToken.current {
            // Access token available -- user already logged in
            // Perform log out
            
            // 2
            loginManager.logOut()
            print("Logged Out")
            
            
        } else {
            // Access token not available -- user already logged out
            // Perform log in
            
            // 3
            loginManager.logIn(permissions: ["email"], from: self) { [weak self] (result, error) in
                
                // 4
                // Check for error
                guard error == nil else {
                    // Error occurred
                    print(error!.localizedDescription)
                    return
                }
                
                // 5
                // Check for cancel
                guard let result = result, !result.isCancelled else {
                    print("User cancelled login")
                    return
                }
              
                // Successfully logged in
                // 6
               print("User Logged IN")
                
                //MARK:- printing logged in user details
                GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        print(result as Any)
                        let fields = result as? [String:Any]
                       
                        let email = fields!["email"] as? String
                        let name = fields!["name"] as? String
                        //Switch to next screen to fill details
                        let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: Constants.segues.SignUpDetailsViewController) as! SignUpDetailsViewController
                         self?.navigationController?.pushViewController(detailVC, animated: true)
                        detailVC.email = email!
                        detailVC.name = name!
                        detailVC.signUpMethod = Constants.signUpMethods.facebook
                    }
                })
                print(result)
                
                // 7
                Profile.loadCurrentProfile { (profile, error) in
                    print(Profile.current as Any)
                   // self?.updateMessage(with: Profile.current?.name)
                }
                
            }
           
            
            
        }
    }
    //MARK:- google sign up
    
    @IBAction func signUpWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("Google Sing In didSignInForUser")
        if let error = error {
          print(error.localizedDescription)
          return
        }
        //here we specify the properties of profile we need like email,name etc.
        let email = user.profile.email
        let name = user.profile.name
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpDetailsViewController") as! SignUpDetailsViewController
        self.navigationController?.pushViewController(detailVC, animated: true)
        detailVC.email = email!
        detailVC.name = name!
        detailVC.signUpMethod = Constants.signUpMethods.google
        detailVC.user = user
        print(email as Any)
        
        //guard let authentication = user.authentication else { return }
//        let credential = GoogleAuthProvider.credential(withIDToken: (authentication.idToken)!, accessToken: (authentication.accessToken)!)
//    // When user is signed in
//        Auth.auth().signIn(with: credential, completion: { (user, error) in
//          if let error = error {
//            print(“Login error: \(error.localizedDescription)”)
//            return
//          }
//        })
      }
      // Start Google OAuth2 Authentication
      func sign(_ signIn: GIDSignIn?, present viewController: UIViewController?) {
      
        // Showing OAuth2 authentication window
        if let aController = viewController {
          present(aController, animated: true) {() -> Void in }
        }
      }
      // After Google OAuth2 authentication
      func sign(_ signIn: GIDSignIn?, dismiss viewController: UIViewController?) {
        // Close OAuth2 authentication window
        dismiss(animated: true) {() -> Void in }
      }
    
}
extension UIButton {
    func underline() {
        guard let title = self.titleLabel else { return }
        guard let tittleText = title.text else { return }
        let attributedString = NSMutableAttributedString(string: (tittleText))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: (tittleText.count)))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
