//
//  Helper.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 30/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FBSDKLoginKit
import CoreData

struct Alert {
    static func errorAlert(title: String, message: String?, cancelButton: Bool = false, loginButton: Bool = false, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) {
            _ in
            guard let completion = completion else { return }
            completion()
        }
        alert.addAction(actionOK)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if cancelButton { alert.addAction(cancel) }
        
        let login = UIAlertAction(title: "Login", style: .default) { (action) in
            print("XOXO")
        }
        if loginButton{alert.addAction(login)}
        
        return alert
    }
    
    
}
class DatabaseHelper{
    
    static var sharedInstance = DatabaseHelper()
    
    let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    //create data
    func createData(email: String, name: String){
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.entity.LoggedInUser)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do{
            try managedContext!.execute(deleteRequest)
            try managedContext!.save()
        }
        catch{
            print ("There was an error")
        }
        
        let userEntity = NSEntityDescription.entity(forEntityName: Constants.entity.LoggedInUser, in: managedContext!)
        let loggedInUser = NSManagedObject(entity: userEntity!, insertInto: managedContext)
        loggedInUser.setValue(email, forKey: Constants.attributes.email)
        loggedInUser.setValue(name, forKey: Constants.attributes.name)
        
        do{
            try managedContext!.save()
        }catch let error as NSError{
            print("could not save \(error), \(error.userInfo)")
        }
    }
    
    func getLoggedInUserDetails() -> Array<Any>{
        var loggedInUser = [String()]
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.entity.LoggedInUser)
        do {
            let user = try managedContext?.fetch(fetchRequest)
            print(user)
            for data in user!{
                loggedInUser = [(data.value(forKey: Constants.attributes.email) as? String)!, (data.value(forKey: Constants.attributes.name) as? String)!]
            }
        } catch  {
            print("Could Not Fetch!")
        }
       return loggedInUser
    }
    
}


