//
//  WaitingViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 14-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class WaitingViewController: UIViewController {
    
    // declare models
    let sio = SocketIOManager.sharedInstance
    let db = FirebaseManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.alertConnection(notification:)), name: Notification.Name("alertConnection"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // add observer and ask server for current rooms
        NotificationCenter.default.addObserver(self, selector: #selector(self.newRooms(notification:)), name: Notification.Name("newRooms"), object: nil)
        sio.getRooms()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func newRooms(notification: Notification) {
        
        // loop over rooms
        for x in Array(sio.rooms.keys) {
            
            // check if a lecture of the current user is open
            if sio.rooms[x]?["lecturer"] as? String == db.userID {
                
                // if so, go to slideView and start the lecture
                sio.currentRoom = Slide(data: sio.rooms[x]!)
                db.startSlides(dirName: (sio.currentRoom?.dirName)!, uniqueID: (sio.currentRoom?.uniqueID)!, timeStamp: (sio.currentRoom?.timeStamp)!, name: (sio.currentRoom?.name)!, numPages: (sio.currentRoom?.numPages)!)
                self.performSegue(withIdentifier: "LecturerStartSlideSegue", sender: nil)
            }
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
}
