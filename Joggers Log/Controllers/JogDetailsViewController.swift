//
//  JogDetailsViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 11/08/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import Firebase

class JogDetailsViewController: UIViewController {

    var distance = Double()
    var duration = String()
    var startDateAndTime = String()
    var speed = Float()
    var pace = Float()
    var jogDurationINSeconds = Int()
    var userEmail = String()
    let db = Firestore.firestore()
    var sender = String()
    
    @IBOutlet var startDateTime: UILabel!
    @IBOutlet var distanceLbl: UILabel!
    @IBOutlet var durationLbl: UILabel!
    @IBOutlet var avgSpeedLbl: UILabel!
    @IBOutlet var avgPaceLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        distanceLbl.text = String(format: "%.2f", distance) + " m"
        startDateTime.text = startDateAndTime
        durationLbl.text = String(duration+"seconds")
        avgSpeedLbl.text = "\(String(format: "%.2f", speed))Km/hr"
        avgPaceLbl.text = "\(String(format: "%.3f", pace))hr/Km"
        //check if the jog details are opened for current jog or from tableview i.e previous jogs
        //sender == map means current jog
        //sender == tableview means from tableview of previous jogs
        if sender == "map"{
            saveToCoreData(distance: distance, duration: jogDurationINSeconds, speed: speed,pace: pace)
            saveToFirebase(distance: distance, duration: jogDurationINSeconds, speed: speed, pace: pace)
            let jd = JogDetails(distance: distance, time: jogDurationINSeconds, avgSpeed: speed, avgPace: pace, dateOfJog: String("\(Date())".prefix(19)))
            logs.append(jd)
//            type(of: jd).init(distance: distance, time: jogDurationINSeconds, avgSpeed: speed, avgPace: pace, dateOfJog: String("\(Date())".prefix(19))
            
            
        }
        
    }
    
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    //MARK:- Saving data to mobile storage
    func saveToCoreData(distance: Double,duration: Int,speed: Float,pace: Float){
        DatabaseHelper.sharedInstance.saveJogDetails(date: String("\(Date())".prefix(19)),
                                                     distance: distance,
                                                     duration: jogDurationINSeconds,
                                                     speed: speed,
                                                     pace: pace)
    }
    
    //MARK:- save jog details to firebase
    func saveToFirebase(distance: Double,duration: Int,speed: Float,pace: Float){
        let savingDateTime = Date()
        self.db.collection("JogDetails").document("Details").collection("\((Auth.auth().currentUser?.email!)!)").document(String("\(savingDateTime)".prefix(19))).setData([
            "distance": distance,
            "duration": duration,
            "speed": speed,
            "pace": pace
        ]) { err in
            if let err = err {
                Alert.errorAlert(title: "Error", message: "There was an error Signing up!\(err)")
            } else {
                print("Document successfully written!")
                
            }
        }
    }

    
}

extension Date {

 static func getCurrentDate() -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd/MM/yyyy"

        return dateFormatter.string(from: Date())

    }
}


