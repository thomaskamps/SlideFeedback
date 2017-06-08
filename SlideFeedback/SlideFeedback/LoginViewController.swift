//
//  ViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 07-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var db: FirebaseManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Authentication check
        Auth.auth().addStateDidChangeListener() { auth, user in
            
            // If user is authenticated, perform segue to main app screen
            if user != nil {
                self.db.userID = Auth.auth().currentUser?.uid
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
        
        self.db = FirebaseManager.sharedInstance
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login() {
        if userName.text! != "" && password.text! != "" {
            Auth.auth().signIn(withEmail: userName.text!, password: password.text!) {(user, error) in
                
                if error == nil {
                    
                    self.db.userID = Auth.auth().currentUser?.uid
                    
                } else {
                    
                    self.alert(title: "Something went wrong", message: "Unfortunately something went wrong. Info: \(String(describing: error))")
                }
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

}

