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
        userID = Auth.auth().currentUser?.uid
    }
    
    var ref = Database.database().reference()
    var userID: String?
    
    // Log in and automatically set userID
    func login(email: String, password: String) throws {
        Auth.auth().signIn(withEmail: email, password: password)
        self.userID = Auth.auth().currentUser?.uid
    }
    
    func logOut() throws {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            throw signOutError
        }
    }
    
}
