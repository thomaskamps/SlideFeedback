//
//  LecturerSlideViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 14-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class LecturerSlideViewController: UIViewController, UIWebViewDelegate {
    
    // declare outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slideView: UIWebView!
    @IBOutlet weak var menuBar: UIView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBAction func nextButton(_ sender: Any) {
        
        // check if page exists
        if (sio.currentRoom?.currentPage)! < ((sio.currentRoom?.numPages)! - 1) {
            
            // push new page to the server and load yourself
            sio.pageUp()
            slideViewLoad(urlString: (sio.currentRoom?.buildUrlString())!)
        }
    }
    
    @IBAction func previousButton(_ sender: Any) {
        
        // check if page exists
        if (sio.currentRoom?.currentPage)! > 0 {
            
            // push new page to the server and load yourself
            sio.pageDown()
            slideViewLoad(urlString: (sio.currentRoom?.buildUrlString())!)
        }
    }
    
    @IBAction func endSlideButton(_ sender: Any) {
        
        // push endLecture notification to server and dismiss view
        sio.endLecture()
        self.dismiss(animated: true, completion: nil)
    }
    
    // declare vars and models
    let sio = SocketIOManager.sharedInstance
    let db = FirebaseManager.sharedInstance
    var currentNegativeFeedback = 0
    var currentPositiveFeedback = 0
    let neutralColor = UIColor(red:0.56, green:0.75, blue:0.66, alpha:1.0)
    let alertColor = UIColor(red:0.98, green:0.77, blue:0.27, alpha:1.0)

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.slideView.delegate = self
        
        // check if a room is selected
        if sio.currentRoom != nil {
            
            // become lecturer for the selected lecture and load first slide
            sio.claimLecture()
            slideViewLoad(urlString: (sio.currentRoom?.buildUrlString())!)
            
            // add observers
            NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNegativeFeedback(notification:)), name: Notification.Name("receiveNegativeFeedback"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.receivePositiveFeedback(notification:)), name: Notification.Name("receivePositiveFeedback"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.alertConnection(notification:)), name: Notification.Name("alertConnection"), object: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func slideViewLoad(urlString: String) {
        
        // reset feedback indications to neutral
        self.currentPositiveFeedback = 0
        self.currentNegativeFeedback = 0
        self.menuBar.backgroundColor = self.neutralColor
        self.feedbackLabel.text = ""
        
        // load new slide
        let url: NSURL! = NSURL(string: urlString)
        self.slideView.loadRequest(NSURLRequest(url: url as URL) as URLRequest)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        // resize content and stop activityIndicator when finished loading
        self.slideView.resizeWebContent()
        activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        // start activityIndicator
        activityIndicator.startAnimating()
    }
    
    func receiveNegativeFeedback(notification: Notification) {
        
        // save feedback to db
        db.saveFeedback(uniqueID: (sio.currentRoom?.uniqueID)!, currentPage: (sio.currentRoom?.currentPage)!, feedback: "negative", studentCount: sio.currentStudentCount ?? 1)
        
        // process in view
        self.currentNegativeFeedback += 1
        self.processFeedback()
    }
    
    func receivePositiveFeedback(notification: Notification) {
        
        // save feedback to db
        db.saveFeedback(uniqueID: (sio.currentRoom?.uniqueID)!, currentPage: (sio.currentRoom?.currentPage)!, feedback: "positive", studentCount: sio.currentStudentCount ?? 1)
        
        // process in view
        self.currentPositiveFeedback += 1
        self.processFeedback()
    }
    
    func processFeedback() {
        
        // process the current feedback if more than half is negative
        if self.currentNegativeFeedback >= self.currentPositiveFeedback {
            
            // substract feedbacks to calculate effective feedback, then calculate ratio with number of students
            let effectiveFeedback = self.currentNegativeFeedback - self.currentPositiveFeedback
            let feedbackRatio = self.getFeedbackRatio(effectiveFeedback: effectiveFeedback)
            
            // update view to new feedback
            let label = String(Int(feedbackRatio*100)) + "% of students think the pace is too high"
            self.updateFeedbackView(ratio: feedbackRatio, label: label)
        
        // process the current feedback if more than half is positive
        } else {
            
            // substract feedbacks to calculate effective feedback, then calculate ratio with number of students
            let effectiveFeedback = self.currentPositiveFeedback - self.currentNegativeFeedback
            let feedbackRatio = self.getFeedbackRatio(effectiveFeedback: effectiveFeedback)
            
            // update view to new feedback
            let label = String(Int(feedbackRatio*100)) + "% of students think the pace is too low"
            self.updateFeedbackView(ratio: feedbackRatio, label: label)
            
        }
    }
    
    func getFeedbackRatio(effectiveFeedback: Int) -> Float {
        
        // check if a valid student count is there
        if sio.currentStudentCount != nil && sio.currentStudentCount != 0 {
            
            // calculate ratio
            let temp = Float(effectiveFeedback) / Float(sio.currentStudentCount!)
            return temp
            
        // else return 0
        } else {
            
            return Float(0)
        }
    }
    
    func updateFeedbackView(ratio: Float, label: String) {
        
        // treshold is 0.3
        if ratio > 0.3 {
            
            // alert lecturer
            self.menuBar.backgroundColor = self.alertColor
            self.feedbackLabel.text = label
            
        } else {
            
            // go back to neutral
            self.menuBar.backgroundColor = self.neutralColor
            self.feedbackLabel.text = ""
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

}
