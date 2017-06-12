//
//  SlidelistViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 08-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit
import Firebase
import SocketIO

class SlidelistViewController: UIViewController {
    
    //var items: Array<String>?
    var itemsInfo: [String: [String:Any]] = [:]
    var items: Array<String>? = []
    
    let sio = SocketIOManager.sharedInstance

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.newRooms(notification:)), name: Notification.Name("newRooms"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if sio.rooms != nil {
            self.itemsInfo = sio.rooms!
            self.items = Array(self.itemsInfo.keys)
            tableView.reloadData()
        }
    }
    
    func newRooms(notification: Notification) {
        if sio.rooms != nil {
            self.itemsInfo = sio.rooms!
            self.items = Array(self.itemsInfo.keys)
            tableView.reloadData()
        }
    }
    
}

extension SlidelistViewController: UITableViewDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "startSlideSegue" {
            
            let vc = segue.destination as? SlideViewController
            let index = items?[(tableView.indexPathForSelectedRow?.row)!]
            vc?.dirName = itemsInfo[index!]?["dirName"] as? String
            vc?.numPages = itemsInfo[index!]?["numPages"] as? Int
            vc?.currentPage = itemsInfo[index!]?["currentPage"] as? Int
            vc?.name = index
        }
    }
    
}

extension SlidelistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (items != nil) {
            return items!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "slideCell", for: indexPath) as! SlideTableViewCell
        
        if let temp = items {
            cell.cellLabel.text = temp[indexPath.row]
        } else {
            print("error in items..")
        }
        
        return cell
        
    }
}
