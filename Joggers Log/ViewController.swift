//
//  ViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 25/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var logIn: UIButton!
    @IBOutlet var signUp: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        logIn.layer.borderWidth = 1
        logIn.layer.borderColor = UIColor.white.cgColor
        logIn.layer.cornerRadius = logIn.frame.height/2
        signUp.layer.borderWidth = 1
        signUp.layer.borderColor = UIColor.white.cgColor
        signUp.layer.cornerRadius = logIn.frame.height/2
        // Do any additional setup after loading the view.
    }


}

