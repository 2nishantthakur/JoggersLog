//
//  Helper.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 30/07/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import Foundation
import UIKit

struct Alert {
    static func errorAlert(title: String, message: String?, cancelButton: Bool = false, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) {
            _ in
            guard let completion = completion else { return }
            completion()
        }
        alert.addAction(actionOK)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if cancelButton { alert.addAction(cancel) }
        
        return alert
    }
}
