//
//  WaitingViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 14-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class WaitingViewController: UIViewController {
    
    let sio = SocketIOManager.sharedInstance
    let db = FirebaseManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.newRooms(notification:)), name: Notification.Name("newRooms"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newRooms(notification: Notification) {
        
        for x in Array(sio.rooms.keys) {
            
            if sio.rooms[x]?["lecturer"] as? String == db.userID {
                
                sio.currentRoom = Slide(data: sio.rooms[x]!)
                self.performSegue(withIdentifier: "LecturerStartSlideSegue", sender: nil)
            }
        }
    }
}
