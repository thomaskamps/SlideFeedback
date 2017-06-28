//
//  SlideViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 22-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class HistorySlideViewController: UIViewController, UIWebViewDelegate {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slideView: UIWebView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBAction func nextButton(_ sender: Any) {
        
        if (self.currentPresentation?.currentPage)! < ((self.currentPresentation?.numPages)! - 1) {
            
            self.currentPresentation?.currentPage += 1
            slideViewLoad(urlString: (self.currentPresentation?.buildUrlString())!)
        }
    }
    
    @IBAction func previousButton(_ sender: Any) {
        
        if (self.currentPresentation?.currentPage)! > 0 {
            
            self.currentPresentation?.currentPage -= 1
            slideViewLoad(urlString: (self.currentPresentation?.buildUrlString())!)
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let db = FirebaseManager.sharedInstance
    var currentPresentation: Slide?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.slideView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.alertConnection(notification:)), name: Notification.Name("alertConnection"), object: nil)
        
        if self.currentPresentation != nil {
            
            slideViewLoad(urlString: (self.currentPresentation?.buildUrlString())!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideViewLoad(urlString: String) {
        
        let url: NSURL! = NSURL(string: urlString)
        self.slideView.loadRequest(NSURLRequest(url: url as URL) as URLRequest)
        
        if let feedback = db.history?[(self.currentPresentation?.uniqueID)!]?["feedback"] as? [String: Any] {
            
            let feedbackProcessed = self.getFeedback(feedbackData: feedback as! [String : [String : Any]])
            
            if feedbackProcessed["negative"] == 0 && feedbackProcessed["positive"] == 0 {
                
                let feedbackString = "No feedback"
                self.feedbackLabel.text = feedbackString
                
            } else {
                
                let negative = feedbackProcessed["negative"]!
                let positive = feedbackProcessed["positive"]!
                let studentCount = feedbackProcessed["studentCount"]!
                
                var feedbackString = "Feedback: " + String(describing: positive) + " positive, " + String(describing: negative) + " negative"
                
                if self.db.role == 20 {
                    feedbackString += ", number of students: " + String(describing: studentCount)
                }
                
                self.feedbackLabel.text = feedbackString
            }
        } else {
            
            let feedbackString = "No feedback"
            self.feedbackLabel.text = feedbackString
        }
    }
    
    func getFeedback(feedbackData: [String:[String:Any]]) -> [String: Int] {
        
        var returnFeedback: [String:Int] = ["negative": 0, "positive": 0, "studentCount": 1]
        var total = 0
        var count = 0
        
        for x in feedbackData.keys {
            
            let page = feedbackData[x]?["page"] as! Int
            let feedback = feedbackData[x]?["feedback"] as! String
            let studentCount = feedbackData[x]?["studentCount"] as? Int ?? 1
            
            if (feedback == "positive" || feedback == "negative") && page == self.currentPresentation?.currentPage {
                returnFeedback[feedback]! += 1
                total += studentCount
                count += 1
            }
        }
        
        if total != 0 && count != 0 {
            returnFeedback["studentCount"] = total / count
        }
        return returnFeedback
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        self.slideView.resizeWebContent()
        activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        activityIndicator.startAnimating()
    }

}
