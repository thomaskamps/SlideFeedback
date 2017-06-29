//
//  SlidelistViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 08-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class SlidelistViewController: UIViewController {
    
    // declare outlets
    @IBOutlet weak var tableView: UITableView!
    
    // declare models
    let sio = SocketIOManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // add observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.alertConnection(notification:)), name: Notification.Name("alertConnection"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // on viewDidAppear ask server for current rooms and add observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.newRooms(notification:)), name: Notification.Name("newRooms"), object: nil)
        sio.getRooms()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func newRooms(notification: Notification) {
        
        // on newRooms event reload the tableView
        tableView.reloadData()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension SlidelistViewController: UITableViewDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "startSlideSegue" {
            
            // get dirName for the selected slides and join the room for those
            let dirName = sio.rooms[Array(sio.rooms.keys)[(tableView.indexPathForSelectedRow?.row)!]]?["dirName"] as? String
            sio.joinRoom(room: dirName!)
        }
    }
    
}

extension SlidelistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // count number of open slides
        return sio.rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create cell for tableView
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "slideCell", for: indexPath) as! SlideTableViewCell
        cell.cellLabel.text = sio.rooms[Array(sio.rooms.keys)[indexPath.row]]?["name"] as? String

        return cell
        
    }
}
