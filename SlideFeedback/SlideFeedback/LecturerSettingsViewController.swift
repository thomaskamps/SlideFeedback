//
//  LecturerSettingsViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 20-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class LecturerSettingsViewController: UIViewController {
    
    var db = FirebaseManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedOut(notification:)), name: Notification.Name("userLoggedOut"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        
        do {
            
            try db.logOut()
            
        } catch let error as NSError {
            
            self.alert(title: "Unfortunately something went wrong", message: String(describing: error))
        }
    }
    
    func userLoggedOut(notification: Notification) {
        self.performSegue(withIdentifier: "logOutSegue", sender: nil)
    }
}
