//
//  LecturerSlideViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 14-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class LecturerSlideViewController: UIViewController, UIWebViewDelegate {
        
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slideView: UIWebView!
    @IBOutlet weak var menuBar: UIView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBAction func nextButton(_ sender: Any) {
        
        if (sio.currentRoom?.currentPage)! < ((sio.currentRoom?.numPages)! - 1) {
            
            sio.pageUp()
            slideViewLoad(urlString: (sio.currentRoom?.buildUrlString())!)
        }
    }
    
    @IBAction func previousButton(_ sender: Any) {
        
        if (sio.currentRoom?.currentPage)! > 0 {
            
            sio.pageDown()
            slideViewLoad(urlString: (sio.currentRoom?.buildUrlString())!)
        }
    }
    
    @IBAction func endSlideButton(_ sender: Any) {
        
        sio.endLecture()
        self.dismiss(animated: true, completion: nil)
    }
    
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
        
        if sio.currentRoom != nil {
            
            sio.claimLecture()
            
            slideViewLoad(urlString: (sio.currentRoom?.buildUrlString())!)
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
        
        let url: NSURL! = NSURL(string: urlString)
        self.slideView.loadRequest(NSURLRequest(url: url as URL) as URLRequest)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        self.slideView.resizeWebContent()
        activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        activityIndicator.startAnimating()
    }
    
    func receiveNegativeFeedback(notification: Notification) {
        
        db.saveFeedback(uniqueID: (sio.currentRoom?.uniqueID)!, currentPage: (sio.currentRoom?.currentPage)!, feedback: "negative", studentCount: sio.currentStudentCount ?? 1)
        self.currentNegativeFeedback += 1
        self.processFeedback()
        //self.alert(title: "You received feedback", message: "Unfortunately it is negative")
    }
    
    func receivePositiveFeedback(notification: Notification) {
        
        db.saveFeedback(uniqueID: (sio.currentRoom?.uniqueID)!, currentPage: (sio.currentRoom?.currentPage)!, feedback: "positive", studentCount: sio.currentStudentCount ?? 1)
        self.currentPositiveFeedback += 1
        self.processFeedback()
        //self.alert(title: "You received feedback", message: "Yeah it is positive")
    }
    
    func processFeedback() {
        
        if self.currentNegativeFeedback >= self.currentPositiveFeedback {
            let effectiveFeedback = self.currentNegativeFeedback - self.currentPositiveFeedback
            let feedbackRatio = self.getFeedbackRatio(effectiveFeedback: effectiveFeedback)
            if feedbackRatio > 0.3 {
                self.menuBar.backgroundColor = self.alertColor
                self.feedbackLabel.text = String(Int(feedbackRatio*100)) + "% of students are negative"
            } else {
                self.menuBar.backgroundColor = self.neutralColor
                self.feedbackLabel.text = ""
            }
            
        } else {
            let effectiveFeedback = self.currentPositiveFeedback - self.currentNegativeFeedback
            let feedbackRatio = self.getFeedbackRatio(effectiveFeedback: effectiveFeedback)
            if feedbackRatio > 0.3 {
                self.menuBar.backgroundColor = self.alertColor
                self.feedbackLabel.text = String(Int(feedbackRatio*100)) + "% of students are positive"
            } else {
                self.menuBar.backgroundColor = self.neutralColor
                self.feedbackLabel.text = ""
            }
        }
    }
    
    func getFeedbackRatio(effectiveFeedback: Int) -> Float {
        if sio.currentStudentCount != nil && sio.currentStudentCount != 0 {
            let temp = Float(effectiveFeedback) / Float(sio.currentStudentCount!)
            print(temp)
            return temp
        } else {
            return Float(0)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
