//
//  HamBurgerMenuViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 31/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import FirebaseFirestore
import Firebase

class HamBurgerMenuViewController: UIViewController {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var me: UIButton!
    
    let db = Firestore.firestore()
    var profileImage = UIImage()
    var UserImage = String()
    var loggedInUser = [String()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      
        image.layer.cornerRadius = image.frame.height/2
        //check if core data has user details if yes then show them otherwise check details in firestore
        checkCoreDataForUserDetails()
        //check for facebook login and then if logged in using fb then load profile pic
        loadFacebookProfilePic()
        
        
    }
    
    @IBAction func meButton(_ sender: Any) {
        me.backgroundColor = UIColor(red: 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        startButton.backgroundColor = .white
        settingsButton.backgroundColor = .white
    }
    @IBAction func startButtonClicked(_ sender: Any) {
        startButton.backgroundColor = UIColor(red: 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        me.backgroundColor = .white
        settingsButton.backgroundColor = .white
    }
    @IBAction func settingsButtonClicked(_ sender: Any) {
        settingsButton.backgroundColor = UIColor(red: 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        startButton.backgroundColor = .white
        me.backgroundColor = .white
    }
    
    func checkCoreDataForUserDetails() {
        loggedInUser =  DatabaseHelper.sharedInstance.getLoggedInUserDetails() as! [String]
        print(loggedInUser)
        print(loggedInUser.count)
        if loggedInUser.count == 2{
            name.text = loggedInUser[1]
        }else{
            loggedInUser = [(Auth.auth().currentUser?.email)!, (Auth.auth().currentUser?.displayName)!]
            print(loggedInUser)
            name.text = loggedInUser[1]
        }
    }
    
    
    func loadFacebookProfilePic(){
        Profile.loadCurrentProfile { (profile, error) in
            print(Profile.current as Any)
            print(Profile.current?.userID)
            if let userID = Profile.current?.userID{
                self.getProfPic(fid: userID)
                print(userID)
            }
            print(AccessToken.current)
            
        }
    }
    func getProfPic(fid: String?) {
        if (fid != "") {
    //        let imgURLString = "http://graph.facebook.com/" + fid! + "/picture?type=large&access_token=0x600003baf600" //type=normal
            let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(200).height(200)"])
            graphRequest.start(completionHandler: { (connection, result, error) in
                if error != nil {
                    print("Error",error!.localizedDescription)
                }
                else{
                    print(result!)
                    let field = result! as? [String:Any]
                    //self.userNameLabel.text = field!["name"] as? String
                    if let imageURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        print(imageURL)
                        let url = URL(string: imageURL)
                        let data = NSData(contentsOf: url!)
                        let image = UIImage(data: data! as Data)
                        self.name.text = field!["name"] as? String
                        self.image.image = image
                    }
                }
            })
            
        }
    }
    
    
    
}
