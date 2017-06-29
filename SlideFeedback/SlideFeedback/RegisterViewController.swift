//
//  RegisterViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 07-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // declare outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    // declare model
    var db = FirebaseManager.sharedInstance

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func registerAction(_ sender: Any) {
        
        // check if everything is filled in
        if self.nameField.text! != "" && self.emailField.text! != "" && self.passwordField.text! != "" && self.confirmPasswordField.text! != "" {
            
            // check if passwords match
            if self.passwordField.text! == self.confirmPasswordField.text! {
                
                do {
                    // try to create user
                    try db.createUser(name: self.nameField.text!, password: self.passwordField.text!, email: self.emailField.text!)
                    
                } catch let registerError as NSError {
                    
                    self.alert(title: "Something went wrong", message: "Unfortunately something went wrong. Info: \(registerError)")
                }
                
            } else {
                
                self.alert(title: "Passwords don't match", message: "Please re-type your passwords")
                self.passwordField.text = ""
                self.confirmPasswordField.text = ""
            }
            
        } else {
            
            self.alert(title: "Wrong entry", message: "Please enter valid information.")
        }
    }
    
    func userStatusChanged(notification: Notification) {
        
        // when logged in segue to main screen
        self.performSegue(withIdentifier: "registerLogin", sender: nil)
    }

    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

}
