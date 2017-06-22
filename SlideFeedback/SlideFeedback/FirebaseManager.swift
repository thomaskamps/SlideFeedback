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
            } else {
                
                NotificationCenter.default.post(name: Notification.Name("userLoggedOut"), object: nil)
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
    
    func createUser(name: String, password: String, email: String) throws {
        
        var registerError: Any?
        
        Auth.auth().createUser(withEmail: email, password: password) {(user, error) in
            registerError = error
            
            if error == nil {
                self.ref.child("users").child((user?.uid)!).setValue(["name": name, "role": 10])
            }
        }
        
        if registerError == nil {
            
            do {
                
                try self.login(email: email, password: password)
                
            } catch let loginError as NSError {
                
                throw loginError
            }
            
        } else {
            
            throw registerError as! NSError
        }
        
    }
    
    func startSlides(dirName: String, uniqueID: String, timeStamp: String) {
        
        let data = ["dirName": dirName, "timeStamp": timeStamp]
        
        if self.role == 20 {
            
            self.ref.child("presentations").child(uniqueID).setValue(data)
        }
    }
    
    func saveFeedbackLecturer(uniqueID: String, currentPage: Int, feedback: String) {
        
        let feedbackRef = self.ref.child("users").child(self.userID!).child("presentations").child(uniqueID).child(String(currentPage)).child(feedback)
        
        feedbackRef.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            
            var value = currentData.value as? Int
            print(value)
            if value == nil {
                value = 0
            }
            currentData.value = value! + 1
            print(currentData.value)
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    func saveFeedbackStudent(uniqueID: String, currentPage: Int, feedback: String) {
        
        self.ref.child("users").child(self.userID!).child("saved_slides").child(uniqueID).child(String(currentPage)).setValue(feedback)
    }
    
}
