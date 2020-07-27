//
//  SignUpDetailsViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 27/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class SignUpDetailsViewController: UIViewController {

    @IBOutlet var Email: SkyFloatingLabelTextField!
    @IBOutlet var name: SkyFloatingLabelTextField!
    @IBOutlet var dob: SkyFloatingLabelTextField!
    @IBOutlet var gender: SkyFloatingLabelTextField!
    @IBOutlet var signUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        signUpButton.layer.cornerRadius = signUpButton.frame.height/2
        // Do any additional setup after loading the view.
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
