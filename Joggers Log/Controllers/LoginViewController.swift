//
//  LoginViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 26/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import CoreData

class LoginViewController: UIViewController, GIDSignInDelegate {
    
    @IBOutlet var continueWithGoogle: UIButton!
    @IBOutlet var continueWithFacebook: UIButton!
    @IBOutlet var signUp: UIButton!
    @IBOutlet var loading: UIActivityIndicatorView!
    
    var userAlreadyRegistered = Bool()
    var signUpMethod = String()
    var user = GIDGoogleUser()
    var UserName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading.isHidden = true
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        setButtonProperties()
        // Do any additional setup after loading the view.
    }
    @IBAction func continueWithGoogleButton(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
        loading.isHidden = false
        loading.startAnimating()
        signUpMethod = Constants.signUpMethods.google
    }
    @IBAction func continueWithFacebookButton(_ sender: UIButton) {
        signUpMethod = Constants.signUpMethods.facebook
        loading.isHidden = false
        loading.startAnimating()
        
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
                        self!.UserName = name!
                        self!.checkIfUserAlreadyExists(email: email!, complete:{
                            if self!.userAlreadyRegistered == false{
                                //SignUp required
                                let alert = UIAlertController.init(title: "Account not found!", message: "Please SignUp first", preferredStyle: .alert)
                                let action = UIAlertAction(title: "SignUp", style: .default) { (action) in
                                    let SignUpVC = self?.storyboard?.instantiateViewController(withIdentifier: Constants.VC.SignUpViewController) as? SignUpViewController
                                    self?.navigationController?.pushViewController(SignUpVC!, animated: true)
                                }
                                alert.addAction(action)
                                self!.present(alert, animated: true)
                            }
                            else{
                                self!.checkCredential()
                                //account exists , proceed to authenticate
                                
                            }
                        })
                    }
                })
                
                print(result)
                
                // 7
                Profile.loadCurrentProfile { (profile, error) in
                    print(Profile.current as Any)
                   print(Profile.current?.userID)
                    //self?.updateMessage(with: Profile.current?.name)
                }
                
            }
           
            
            
        }
    }
    func setButtonProperties(){
        continueWithGoogle.layer.cornerRadius = continueWithGoogle.frame.height/2
        continueWithGoogle.layer.borderWidth = 2
        continueWithGoogle.layer.borderColor = UIColor.gray.cgColor
        continueWithGoogle.imageView?.contentMode = .scaleAspectFit
        continueWithFacebook.layer.cornerRadius = continueWithFacebook.frame.height/2
        signUp.underline()
    }
    
    
    
}


extension LoginViewController{
    func sign(_ signIn: GIDSignIn!, didSignInFor user1: GIDGoogleUser!, withError error: Error!) {
        print("Google Sing In didSignInForUser")
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let email = user1.profile.email
        UserName = user1.profile.name
        print(Auth.auth().currentUser?.email)
        print(email as Any)
        user = user1
        
        checkIfUserAlreadyExists(email: email!, complete:{
            if self.userAlreadyRegistered == false{
                //SignUp required
                let alert = UIAlertController.init(title: "Account not found!", message: "Please SignUp first", preferredStyle: .alert)
                let action = UIAlertAction(title: "SignUp", style: .default) { (action) in
                    let SignUpVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.VC.SignUpViewController) as? SignUpViewController
                    self.navigationController?.pushViewController(SignUpVC!, animated: true)
                }
                alert.addAction(action)
                self.present(alert, animated: true)
            }
            else{
                self.checkCredential()
                //account exists , proceed to authenticate
                
            }
        })
       
        
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
    func checkCredential(){
        //MARK:-  if user signed in using facebook
        if signUpMethod == Constants.signUpMethods.facebook{
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            firebaseSignUp(credential: credential)
        }
            
            //MARK:- else if user signed in using google
        else{
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            firebaseSignUp(credential: credential)
        }
    }
    func checkIfUserAlreadyExists(email: String, complete: @escaping()->()){
        
        Auth.auth().fetchProviders(forEmail: email, completion: {
            (providers, error) in
            print(providers)
            if let error = error {
                print(error.localizedDescription)
                
            } else if providers != nil{
                print("User already registered. Login")
                self.userAlreadyRegistered = true
                complete()
            }else{
                self.userAlreadyRegistered = false
                complete()
            }
        })
    }
    
    func firebaseSignUp(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let authError = error as NSError
                if (authError.code == AuthErrorCode.secondFactorRequired.rawValue) {
                    // The user is a multi-factor user. Second factor challenge is required.
                    let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in (resolver.hints) {
                        displayNameString += tmpFactorInfo.displayName ?? ""
                        displayNameString += " "
                    }
                    self.showTextInputPrompt(withMessage: "Select factor to sign in\n\(displayNameString)", completionBlock: { userPressedOK, displayName in
                        var selectedHint: PhoneMultiFactorInfo?
                        for tmpFactorInfo in resolver.hints {
                            if (displayName == tmpFactorInfo.displayName) {
                                selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                            }
                        }
                        PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                            if error != nil {
                                print("Multi factor start sign in failed. Error: \(error.debugDescription)")
                            } else {
                                self.showTextInputPrompt(withMessage: "Verification code for \(selectedHint?.displayName ?? "")", completionBlock: { userPressedOK, verificationCode in
                                    let credential: PhoneAuthCredential? = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode!)
                                    let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator.assertion(with: credential!)
                                    resolver.resolveSignIn(with: assertion!) { authResult, error in
                                        if error != nil {
                                            print("Multi factor finanlize sign in failed. Error: \(error.debugDescription)")
                                        } else {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                })
                            }
                        }
                    })
                } else {
                    self.showMessagePrompt(error.localizedDescription)
                    self.loading.stopAnimating()
                    self.loading.isHidden = true
                    return
                }
                // ...
                return
            }
            
            
            //MARK:-  User is Logged in
            //save userDetails to CoreData
            DatabaseHelper.sharedInstance.createData(email: (Auth.auth().currentUser?.email)!, name:self.UserName)
            
            print(Auth.auth().currentUser?.email)
            self.loading.stopAnimating()
            self.loading.isHidden = true
            let mainVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.VC.LoggedInViewController) as? LoggedInViewController
            self.navigationController?.pushViewController(mainVC!, animated: true)
//              
        }
    }
    func showTextInputPrompt(withMessage message: String,
                             completionBlock: @escaping ((Bool, String?) -> Void)) {
        let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionBlock(false, nil)
        }
        weak var weakPrompt = prompt
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let text = weakPrompt?.textFields?.first?.text else { return }
            completionBlock(true, text)
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(cancelAction)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    func showMessagePrompt(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
    }
    
    //MARK:- coreData
    //create data
    func createData(email: String, name: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: Constants.entity.LoggedInUser, in: managedContext)
        let loggedInUser = NSManagedObject(entity: userEntity!, insertInto: managedContext)
        loggedInUser.setValue(email, forKey: Constants.attributes.email)
        loggedInUser.setValue(name, forKey: Constants.attributes.name)
        
        do{
            try managedContext.save()
        }catch let error as NSError{
            print("could not save \(error), \(error.userInfo)")
        }
    }
}
