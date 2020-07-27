//
//  LoginViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 26/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var continueWithGoogle: UIButton!
    @IBOutlet var continueWithFacebook: UIButton!
    @IBOutlet var signUp: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setButtonProperties()
        // Do any additional setup after loading the view.
    }
    func setButtonProperties(){
        continueWithGoogle.layer.cornerRadius = continueWithGoogle.frame.height/2
        continueWithGoogle.layer.borderWidth = 2
        continueWithGoogle.layer.borderColor = UIColor.gray.cgColor
        continueWithGoogle.imageView?.contentMode = .scaleAspectFit
        continueWithFacebook.layer.cornerRadius = continueWithFacebook.frame.height/2
        signUp.underline()
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
