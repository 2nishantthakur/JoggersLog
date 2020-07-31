//
//  SignUpDetailsViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 27/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import FirebaseFirestore


class SignUpDetailsViewController: UIViewController {
    
    let db = Firestore.firestore()
    var email = String()
    var name = String()
    var signUpMethod = String()
    var user = GIDGoogleUser()
    
    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet var emailTextfield: SkyFloatingLabelTextField!
    @IBOutlet var nameTextfield: SkyFloatingLabelTextField!
    @IBOutlet var dobTextfield: SkyFloatingLabelTextField!
    @IBOutlet var genderTextfield: SkyFloatingLabelTextField!
    @IBOutlet var signUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(email)
        emailTextfield.text = email
        nameTextfield.text = name
        loading.isHidden = true
        signUpButton.layer.cornerRadius = signUpButton.frame.height/2
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func signUpButton(_ sender: UIButton) {
        loading.isHidden = false
        loading.startAnimating()
        //check if textfields are empty
        if (emailTextfield.text != "" && nameTextfield.text != "" && dobTextfield.text != "" && genderTextfield.text != "") {
            let dobArray = dobTextfield.text!.map( { String($0) })
            if genderTextfield.text!.count > 1{
                let alert = Alert.errorAlert(title: "Error", message: "Enter only M,F,O for Male,Female,Other respectively.")
                present(alert, animated: true)
                loading.stopAnimating()
                loading.isHidden = true
            }
                //check if format of dob is correct or not
                
            else if dobArray.count != 10{
                let alert = Alert.errorAlert(title: "Error", message: "Enter Date of birth in correctly")
                present(alert, animated: true)
                loading.stopAnimating()
                loading.isHidden = true
            }else{
                if dobArray[2] != "/" || dobArray[5] != "/"{
                    let alert = Alert.errorAlert(title: "Error", message: "Enter Date of birth in the format DD/MM/YYYY")
                    present(alert, animated: true)
                    loading.stopAnimating()
                    loading.isHidden = true
                }
                else{
                    // all info is correctly entered proceed to complete signUp process on Firebase
                    
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
            }
            
        }else{
            let alert = Alert.errorAlert(title: "Error", message: "Enter Details correctly.")
            present(alert, animated: true)
            loading.stopAnimating()
            loading.isHidden = true
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
                    return
                }
                // ...
                return
            }
            
            
            //MARK:-  User is signed in
            var newUser = User()
            newUser.email = self.email
            newUser.name = self.name
            newUser.dob = self.dobTextfield.text!
            newUser.gender = self.genderTextfield.text!
            
            
            // Add a new document in collection "cities"
            self.db.collection("Users").document("\(newUser.email)").setData([
                "email": newUser.email,
                "name": newUser.name,
                "dob": newUser.dob,
                "gender": newUser.gender
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.loading.stopAnimating()
                    self.loading.isHidden = true
                    Alert.errorAlert(title: "Error", message: "There was an error Signing up!\(err)")
                } else {
                    print("Document successfully written!")
                    self.loading.stopAnimating()
                    self.loading.isHidden = true
                    print("Signed In using \(self.signUpMethod)")
                    
                }
            }
            
           
        }
    }
    
    
    
}
