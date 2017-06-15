//
//  FirebaseManager.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 08-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {
    
    static let sharedInstance = FirebaseManager()
    
    private init() {
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            
            if user != nil {
                
                self.userID = Auth.auth().currentUser?.uid
                
                self.ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let value = snapshot.value as? NSDictionary
                    self.role = value?["role"] as? Int
                    NotificationCenter.default.post(name: Notification.Name("userStatusChanged"), object: nil)

                }) { (error) in
                    
                    print(error.localizedDescription)
                }
            }
        }
        
        userID = Auth.auth().currentUser?.uid
    }
    
    var ref = Database.database().reference()
    var userID: String?
    var role: Int?
    
    // Log in and automatically set userID
    func login(email: String, password: String) throws {
        
        var saveError: Any?
        
        Auth.auth().signIn(withEmail: email, password: password) {(user, error) in
            
            saveError = error
        }
        
        if saveError == nil {
            
            self.userID = Auth.auth().currentUser?.uid
            
        } else {
            
            throw saveError as! Error!
        }
    }
    
    func logOut() throws {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            throw signOutError
        }
    }
    
}
