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
import MapKit
import CoreLocation

class LoggedInViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {
    
    var menu: HamBurgerMenuViewController!
    var menuOut = false
    let locationManager = CLLocationManager()
    var distance = 0.00
    var avgSpeed = Float()
    var avgPace = Float()
    var routeLine: MKPolyline?
    /*your line */
    var routeLineView: MKPolylineRenderer?
    var userLocations = [CLLocationCoordinate2D]()
    var startPressed = false
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var dateString = String()
    var startHour = Int()
    var endHour = Int()
    var startMinute = Int()
    var endMinute = Int()
    var startSecond = Int()
    var endSecond = Int()
    var start = Date()
    
    
    
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var distanceLbl: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var slideingMenuHidingButton: UIButton!
    @IBOutlet var myLocationButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 10.00
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        
        slideingMenuHidingButton.isEnabled = false
        myLocationButton.layer.cornerRadius = 5
        navigationController?.setNavigationBarHidden(true, animated: true)
        menu = storyboard?.instantiateViewController(withIdentifier: "HamBurgerMenuViewController") as? HamBurgerMenuViewController
        self.addChild(menu)
        
        view.addSubview(menu.view)
        menu.view.frame = CGRect(x: -view.frame.width, y: 0, width: self.view.frame.width * 0.75, height: self.view.frame.height)
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func hideSlidingMenu(_ sender: Any) {
        configureMenu(sender: "closeMenu")
        slideingMenuHidingButton.isEnabled = false
        slideingMenuHidingButton.alpha = 0
    }
    @IBAction func openMenu(_ sender: UIButton) {
        slideingMenuHidingButton.alpha = 0.3
        configureMenu(sender: "openMenu")
        slideingMenuHidingButton.isEnabled = true
        
    }
    @IBAction func myLocationButton(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    @IBAction func startButtonPressed(_ sender: Any) {
        
        if startStopButton.titleLabel?.text == "START"{
            locationManager.startUpdatingLocation()
            startPressed = true
           
           
           
            startStopButton.setTitle("STOP", for: .normal)
            
            start = Date()
        }else{
            let now = Date()
           //MARK:-find time difference
            let diff = Int(now.timeIntervalSince1970 - start.timeIntervalSince1970)
            print(diff)
            //time diff in seconds
            let hourDifference = diff/3600
            let minuteDifference = (diff - hourDifference*3600)/60
            let secondDifference = (diff - hourDifference*3600 - minuteDifference*60)
            
            let durationString = ("\(hourDifference)hr \(minuteDifference) min \(secondDifference) sec")
            let totalDurationInHours = Double(hourDifference) + Double(minuteDifference)/60 + Double(secondDifference)/3600
            
            print(totalDurationInHours)
            print(distance/1000)
            avgSpeed = Float(Double(distance/1000)/totalDurationInHours)
            avgPace = Float(totalDurationInHours/(distance/1000))
            startStopButton.setTitle("START", for: .normal)
            startPressed = false
            locationManager.stopUpdatingLocation()
            let jogDetailsVC = storyboard?.instantiateViewController(withIdentifier: Constants.VC.JogDetailsViewController) as! JogDetailsViewController
            jogDetailsVC.distance = distance
            jogDetailsVC.duration = durationString
            jogDetailsVC.startDateAndTime = dateString
            jogDetailsVC.speed = avgSpeed
            jogDetailsVC.pace = avgPace
            jogDetailsVC.jogDurationINSeconds = diff
            jogDetailsVC.userEmail = (Auth.auth().currentUser?.email)!
            jogDetailsVC.sender = "map"
            navigationController?.pushViewController(jogDetailsVC, animated: true)
            print(dateString)
            distance = 0
            userLocations.removeAll()
            startLocation = nil
        }
        
        
    }
    
    func configureMenu(sender: String){
        if sender == "openMenu"{
            UIView.animate(withDuration: 0.3) {
                
                self.menu.view.frame.origin.x = 0
//                print("View Width = \(self.view.frame.width)")
//                print("Slider View Width = \(self.menu.view.frame.width)")
//                print(self.menu.view.frame.origin.x)
            }
            
        }else{
            UIView.animate(withDuration: 0.3) {
                
                self.menu.view.frame.origin.x = -self.menu.view.frame.width
//                print("View Width = \(self.view.frame.width)")
//                print("Slider View Width = \(self.menu.view.frame.width)")
//                print(self.menu.view.frame.origin.x)
            }
        }
        
        
        
    }
    
    
}

extension LoggedInViewController{
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        print(locValue)
        mapView.mapType = MKMapType.standard
        
        self.mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
            }
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
//        if userLocations.count > 1{
//            let lastCoordinate = CLLocation(latitude: userLocations[userLocations.count - 1].latitude, longitude: userLocations[userLocations.count - 1].longitude)
//
//            let secondLastCoordinate = CLLocation(latitude: userLocations[userLocations.count - 2].latitude, longitude: userLocations[userLocations.count - 2].longitude)
//            print(distance)
//            distance = distance + lastCoordinate.distance(from: secondLastCoordinate)
//            distanceLbl.text = distance as? String
//        }
        
        //to draw line on map
        if startPressed == true {
//            userLocations.append(locValue)
//            print(userLocations)
//            print("                                                                                                                                                                                                                                                                                                                                                               ")
//
//            if userLocations.count > 1{
//                let aPolyline = MKPolyline(coordinates: userLocations, count: userLocations.count)
//                mapView.addOverlay(aPolyline)
//            }
            if startLocation == nil {
                startLocation = locations.first
            } else if let location = locations.last {
                let locValue1:CLLocationCoordinate2D = locations.last!.coordinate
                let locValue2:CLLocationCoordinate2D = lastLocation.coordinate
                userLocations = [locValue1, locValue2]
                distance += lastLocation.distance(from: location)
                print("Traveled Distance:",  distance)
                
                print("Straight Distance:", startLocation.distance(from: locations.last!))
                distanceLbl.text = distance as? String
            }
            lastLocation = locations.last
            let aPolyline = MKPolyline(coordinates: userLocations, count: userLocations.count)
                            mapView.addOverlay(aPolyline)

            
        }
        
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRender = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        polylineRender.strokeColor = UIColor.red.withAlphaComponent(1)
        polylineRender.lineWidth = 5
        
        return polylineRender
    }
    
    
}
