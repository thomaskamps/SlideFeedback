//
//  RegisterViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 07-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
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
    
    @IBAction func registerAction(_ sender: Any) {
        
        if self.nameField.text! != "" && self.emailField.text! != "" && self.passwordField.text! != "" && self.confirmPasswordField.text! != "" {
            
            if self.passwordField.text! != self.confirmPasswordField.text! {
                
                do {
                    
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
        self.performSegue(withIdentifier: "registerLogin", sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
