//
//  ViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 07-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var db: FirebaseManager!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.db = FirebaseManager.sharedInstance
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.userStatusChanged(notification:)), name: Notification.Name("userStatusChanged"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func login() {
        
        if userName.text! != "" && password.text! != "" {
            
            do {
                
                try db.login(email: userName.text!, password: password.text!)
                
            } catch let error {
                
                self.alert(title: "Something went wrong..", message: String(describing: error))
            }
        } else {
            
            self.alert(title: "Please enter your credentials", message: "")
        }
    }

    @IBAction func loginAction(_ sender: Any) {
        
        login()
    }
    
    @IBAction func passwordFinished(_ sender: Any) {
        
        login()
    }
    
    func userStatusChanged(notification: Notification) {
        if self.db.role == 20 {
            
            self.performSegue(withIdentifier: "LecturerLoginSegue", sender: nil)
            
        } else {
            
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

