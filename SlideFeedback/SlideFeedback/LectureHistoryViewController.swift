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
        NotificationCenter.default.addObserver(self, selector: #selector(self.alertConnection(notification:)), name: Notification.Name("alertConnection"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        db.getLecturerHistory()
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
            let unique_id =  Array(db.history!.keys)[(tableView.indexPathForSelectedRow?.row)!]
            var data = self.db.history?[unique_id]
            data?["timestamp"] = data?["timeStamp"]
            data?["unique_id"] = unique_id
            data?["currentPage"] = 0
            vc.currentPresentation = Slide(data: data!)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let uniqueID = Array(self.db.history!.keys)[indexPath.row]
            self.db.history!.removeValue(forKey: uniqueID)
            self.db.deletePresentation(uniqueID: uniqueID)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
}

extension LectureHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if db.history != nil {
            return db.history!.keys.count
            
        } else {
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "lecturerHistoryCell", for: indexPath) as! LecturerHistoryTableViewCell
        let test = db.history?[Array(db.history!.keys)[indexPath.row]]
        cell.label.text = (test?["timeStamp"] as? String)! + " - " + (test?["name"] as? String)!
        
        return cell
    }
}
