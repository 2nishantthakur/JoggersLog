//
//  LoggedInViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 31/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class LoggedInViewController: UIViewController {

    var menu: HamBurgerMenuViewController!
    var menuOut = false
    @IBOutlet var slideingMenuHidingButton: UIButton!
    @IBOutlet var myLocationButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

      
        slideingMenuHidingButton.isEnabled = false
        myLocationButton.layer.cornerRadius = 5
        navigationController?.setNavigationBarHidden(true, animated: true)
        menu = storyboard?.instantiateViewController(withIdentifier: "HamBurgerMenuViewController") as? HamBurgerMenuViewController
        self.addChild(menu)
        
        view.addSubview(menu.view)
        menu.view.frame = CGRect(x: -view.frame.width, y: 0, width: self.view.frame.width * 0.75, height: self.view.frame.height)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func hideSlidingMenu(_ sender: UIButton) {
        configureMenu(sender: "closeMenu")
        slideingMenuHidingButton.isEnabled = false
        slideingMenuHidingButton.alpha = 0
    }
    @IBAction func openMenu(_ sender: UIButton) {
        slideingMenuHidingButton.alpha = 0.3
        configureMenu(sender: "openMenu")
        slideingMenuHidingButton.isEnabled = true
        
    }
    func configureMenu(sender: String){
        if sender == "openMenu"{
            UIView.animate(withDuration: 0.3) {
                
                self.menu.view.frame.origin.x = 0
                print("View Width = \(self.view.frame.width)")
                print("Slider View Width = \(self.menu.view.frame.width)")
                print(self.menu.view.frame.origin.x)
            }
            
        }else{
            UIView.animate(withDuration: 0.3) {
                
                self.menu.view.frame.origin.x = -self.menu.view.frame.width
                print("View Width = \(self.view.frame.width)")
                print("Slider View Width = \(self.menu.view.frame.width)")
                print(self.menu.view.frame.origin.x)
            }
        }
        
       
        
    }
    

}
