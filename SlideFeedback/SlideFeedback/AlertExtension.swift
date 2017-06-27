//
//  AlertExtension.swift
//  thomaskamps-pset6
//
//  Created by Thomas Kamps on 15-12-16.
//  Copyright © 2016 Thomas Kamps. All rights reserved.
//

import Foundation
import UIKit

// Extension of the UIViewController for easily displaying alerts
extension UIViewController {
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let oke = UIAlertAction(title: "Oke", style: .default, handler: nil)
        alert.addAction(oke)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertConnection(notification: Notification) {
        self.alert(title: "You seem to have some problems with your connection", message: "Please check if your internet connection is working properly")
    }
    
}
