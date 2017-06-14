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
    
    var dirName: String?
    var name: String?
    var numPages: Int?
    var currentPage: Int?

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
        if sio.rooms != nil {
            for x in Array(sio.rooms!.keys) {
                if sio.rooms![x]?["lecturer"] as! String == db.userID {
                    self.dirName = sio.rooms![x]?["dirName"] as! String
                    self.name = x as! String
                    //print(sio.rooms![x])
                    self.numPages = Int(sio.rooms![x]?["numPages"] as! String)
                    self.currentPage = sio.rooms![x]?["currentPage"] as! Int
                    
                    self.performSegue(withIdentifier: "LecturerStartSlideSegue", sender: nil)
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LecturerStartSlideSegue" {
            
            let vc = segue.destination as? LecturerSlideViewController
            vc?.dirName = self.dirName
            vc?.numPages = self.numPages
            vc?.currentPage = self.currentPage
            vc?.name = self.name
        }
    }

}
