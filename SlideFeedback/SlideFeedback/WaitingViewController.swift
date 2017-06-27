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
        NotificationCenter.default.addObserver(self, selector: #selector(self.alertConnection(notification:)), name: Notification.Name("alertConnection"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.newRooms(notification:)), name: Notification.Name("newRooms"), object: nil)
        sio.getRooms()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func newRooms(notification: Notification) {
        
        for x in Array(sio.rooms.keys) {
            
            if sio.rooms[x]?["lecturer"] as? String == db.userID {
                
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
