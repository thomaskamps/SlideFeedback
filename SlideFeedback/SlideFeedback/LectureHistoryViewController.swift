//
//  LectureHistoryViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 22-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class LectureHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let db = FirebaseManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.newLectureHistory(notification:)), name: Notification.Name("newLectureHistory"), object: nil)
        db.getLecturerHistory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func newLectureHistory(notification: Notification) {
        tableView.reloadData()
    }
}

extension LectureHistoryViewController: UITableViewDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showHistorySegue" {
            
            let vc = segue.destination as! LectureHistorySlideViewController
            var data = db.history[Array(db.history.keys)[(tableView.indexPathForSelectedRow?.row)!]]
            data?["unique_id"] =  Array(db.history.keys)[(tableView.indexPathForSelectedRow?.row)!]
            data?["currentPage"] = 0
            data?["numPages"] = data?["pageCount"]
            data?["timestamp"] = data?["timeStamp"]
            vc.currentPresentation = Slide(data: data!)
        }
    }
    
}

extension LectureHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if db.history != nil {
            return db.history.keys.count
            
        } else {
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "lecturerHistoryCell", for: indexPath) as! LecturerHistoryTableViewCell
        let test = db.history[Array(db.history.keys)[indexPath.row]]
        print(test)
        cell.label.text = (test?["timeStamp"] as? String)! + " - " + (test?["name"] as? String)!
        
        return cell
    }
}
