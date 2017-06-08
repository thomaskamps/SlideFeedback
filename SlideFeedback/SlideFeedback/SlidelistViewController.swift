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
    //var itemsInfo: [String: [String:String]] = [:]
    var items: Array<String>? = ["test", "tesdfdsf", "erewfdsasdasd"]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SlidelistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
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
