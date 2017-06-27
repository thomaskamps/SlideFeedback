//
//  StudentSettingsViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 20-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class StudentSettingsViewController: UIViewController {
    
    var db = FirebaseManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedOut(notification:)), name: Notification.Name("userLoggedOut"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.alertConnection(notification:)), name: Notification.Name("alertConnection"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        
        do {
            
            try db.logOut()
            
        } catch let error as NSError {
            
            self.alert(title: "Something went wrong", message: String(describing: error))
        }
    }

    func userLoggedOut(notification: Notification) {
        self.performSegue(withIdentifier: "logOutSegue", sender: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
