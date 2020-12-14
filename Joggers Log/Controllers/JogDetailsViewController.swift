//
//  JogDetailsViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 11/08/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit

class JogDetailsViewController: UIViewController {

    var distance = Double()
    var duration = String()
    var startDateAndTime = String()
    var speed = Float()
    var pace = Float()
    var jogDurationINSeconds = Int()
    
    @IBOutlet var startDateTime: UILabel!
    @IBOutlet var distanceLbl: UILabel!
    @IBOutlet var durationLbl: UILabel!
    @IBOutlet var avgSpeedLbl: UILabel!
    @IBOutlet var avgPaceLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        distanceLbl.text = String(format: "%.2f", distance) + " m"
        startDateTime.text = startDateAndTime
        durationLbl.text = duration
        avgSpeedLbl.text = "\(String(format: "%.2f", speed))Km/hr"
        avgPaceLbl.text = "\(String(format: "%.3f", pace))hr/Km"
        saveToCoreData(distance: distance, duration: duration, speed: speed, pace: pace)
        print(jogDurationINSeconds)
        print("X")
        
        // Do any additional setup after loading the view.
    }
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    //MARK:- Saving data to mobile storage
    func saveToCoreData(distance: Double,duration: String,speed: Float,pace: Float){
        
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
