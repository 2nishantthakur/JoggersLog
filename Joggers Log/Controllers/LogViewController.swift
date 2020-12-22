//
//  LogViewController.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 15/12/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import CoreData
import Firebase

var logs = [JogDetails()]
//defined globally so that values in array remains in it even if current vc is closed
class LogViewController: UIViewController{
    
    @IBOutlet var checkOnFirebase: UIButton!
    @IBOutlet var noLogs: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    
   
    var jd = JogDetails()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "JogDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        checkOnFirebase.isHidden = true
        checkOnFirebase.isEnabled = false
        noLogs.isHidden = true
        activityIndicator.isHidden = true
        
        checkJogDetailsOnCoredate()
        if logs.count<2{
            checkOnFirebase.isHidden = false
            checkOnFirebase.isEnabled = true
            noLogs.isHidden = false
            tableView.isHidden = true
            tableView.isUserInteractionEnabled = false
        }
        else{
            tableView.reloadData()
            
        }
        if logs.count==1{
            checkJogDetailsDataInFirebase()
        }
        
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func checkOnFirebase(_ sender: Any) {
        checkJogDetailsDataInFirebase()
    }
    
    func checkJogDetailsDataInFirebase(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        db.collection("JogDetails").document("Details").collection("\((Auth.auth().currentUser?.email!)!)").getDocuments { (querySnapshot, error) in
            if error != nil{
                print("Error")
            }else{
                if let snapShotDocuments = querySnapshot?.documents{
                    print(snapShotDocuments.count)
                    self.checkOnFirebase.isHidden = true
                    self.checkOnFirebase.isUserInteractionEnabled = false
                    if snapShotDocuments.count<1{
                        self.noLogs.text = "No previous jogs record found in either offline or online storage!"
                        self.activityIndicator.stopAnimating()
                                                   self.activityIndicator.isHidden = true
                    }
                    else{
                        print(snapShotDocuments)
                        logs.removeAll()
                        DatabaseHelper.sharedInstance.deleteJogDetails()
                        //deleting previous jog record on CoreData
                        for doc in snapShotDocuments{
                            let data = doc.data()
                            print(data)
                            self.jd.distance = data["distance"] as! Double
                            self.jd.avgPace = data["pace"] as! Float
                            self.jd.avgSpeed = data["speed"] as! Float
                            self.jd.time = data["duration"] as! Int
                            self.jd.dateOfJog = doc.documentID
                            logs.append(self.jd)
                            DatabaseHelper.sharedInstance.saveJogDetails(date: self.jd.dateOfJog, distance: self.jd.distance, duration: self.jd.time, speed: self.jd.avgSpeed, pace: self.jd.avgPace)
                            //Adding Data from firebase to local storage
                            self.tableView.reloadData()
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                            self.tableView.isHidden = false
                            self.tableView.isUserInteractionEnabled = true
                            self.noLogs.isHidden = true
                            
                        }
                    }
                    
                }
                
            }
        }
    }
    
    func checkJogDetailsOnCoredate(){
        let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "JogDetail")
        
        do {
            let details = try managedContext?.fetch(fetchRequest)
            //check if the count of data in coredate is same as in logs array
            //if count is same then we wont check in coredate else we will check in coredata and append in logs array
            print(details?.count)
            print(logs.count)
            if (details?.count)!+1 > logs.count{
                let firstLog = logs[0]
                logs = []
                logs.append(firstLog)
                for data in details!{
                    jd.dateOfJog = data.value(forKey: Constants.jogDetails.date) as! String
                    jd.avgSpeed = data.value(forKey: Constants.jogDetails.speed) as! Float
                    jd.distance = data.value(forKey: Constants.jogDetails.distance) as! Double
                    jd.avgPace = data.value(forKey: Constants.jogDetails.pace) as! Float
                    jd.time = data.value(forKey: Constants.jogDetails.duration) as! Int
                    logs.append(jd)
                    tableView.reloadData()
                }
            }
            
        } catch  {
            print("Could Not Fetch!")
        }
    }
    
    

}

extension LogViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! JogDetailTableViewCell
        let dateAndTime = logs[indexPath.row + 1].dateOfJog
        cell.dateLBL.text = String(dateAndTime.prefix(10))
        //select first 10 letters of String dateandtime
        cell.timeLBL.text = String(dateAndTime.suffix(8))
        //select last 9 letters of string
        print(dateAndTime)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/8
        //total of 8 logs will fit on tableview
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailsVC = storyboard?.instantiateViewController(identifier: "JogDetailsViewController") as! JogDetailsViewController
        detailsVC.pace = logs[indexPath.row + 1].avgPace
        detailsVC.speed = logs[indexPath.row + 1].avgSpeed
        detailsVC.distance = logs[indexPath.row + 1].distance
        detailsVC.duration = String(logs[indexPath.row + 1].time)
        detailsVC.startDateAndTime = logs[indexPath.row + 1].dateOfJog
        detailsVC.sender = "tableView"
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    
}
