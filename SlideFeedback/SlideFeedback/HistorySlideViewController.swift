//
//  SlideViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 22-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class HistorySlideViewController: UIViewController, UIWebViewDelegate {

    // declare outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slideView: UIWebView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBAction func nextButton(_ sender: Any) {
        
        // check if page exists
        if (self.currentPresentation?.currentPage)! < ((self.currentPresentation?.numPages)! - 1) {
            
            // load new page
            self.currentPresentation?.currentPage += 1
            slideViewLoad(urlString: (self.currentPresentation?.buildUrlString())!)
        }
    }
    
    @IBAction func previousButton(_ sender: Any) {
        
        // check if page exists
        if (self.currentPresentation?.currentPage)! > 0 {
            
            // load new page
            self.currentPresentation?.currentPage -= 1
            slideViewLoad(urlString: (self.currentPresentation?.buildUrlString())!)
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        // dismiss view, segue created problems with tabBar
        self.dismiss(animated: true, completion: nil)
    }
    
    let db = FirebaseManager.sharedInstance
    var currentPresentation: Slide?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.slideView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.alertConnection(notification:)), name: Notification.Name("alertConnection"), object: nil)
        
        // check if a presentation is selected
        if self.currentPresentation != nil {
            
            // load first slide
            slideViewLoad(urlString: (self.currentPresentation?.buildUrlString())!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideViewLoad(urlString: String) {
        
        // create URL and load slides
        let url: NSURL! = NSURL(string: urlString)
        self.slideView.loadRequest(NSURLRequest(url: url as URL) as URLRequest)
        
        // check if feedback is available
        if let feedback = db.history?[(self.currentPresentation?.uniqueID)!]?["feedback"] as? [String: Any] {
            
            // process feedback
            let feedbackProcessed = self.getFeedback(feedbackData: feedback as! [String : [String : Any]])
            
            // if no feedback is there for this slide
            if feedbackProcessed["negative"] == 0 && feedbackProcessed["positive"] == 0 {
                
                let feedbackString = "No feedback"
                self.feedbackLabel.text = feedbackString
            
            // if there is feedback for this slide
            } else {
                
                let negative = feedbackProcessed["negative"]!
                let positive = feedbackProcessed["positive"]!
                let studentCount = feedbackProcessed["studentCount"]!
                var feedbackString = ""
                
                // check if user is lecturer and create text for feedback accordingly
                if self.db.role == 20 {
                    
                    feedbackString = "Feedback: " + String(describing: positive) + " votes for pace up, " + String(describing: negative) + " votes for pace down, number of students: " + String(describing: studentCount)
                    
                } else {
                    
                    if negative > positive {
                        
                        feedbackString = "You considered the pace too high"
                    } else {
                        
                        feedbackString = "You considered the pace too low"
                    }
                }
                
                // present the feedback
                self.feedbackLabel.text = feedbackString
            }
        
        // if no feedback is available
        } else {
            
            let feedbackString = "No feedback"
            self.feedbackLabel.text = feedbackString
        }
    }
    
    func getFeedback(feedbackData: [String:[String:Any]]) -> [String: Int] {
        
        // prepare vars
        var returnFeedback: [String:Int] = ["negative": 0, "positive": 0, "studentCount": 1]
        var total = 0
        var count = 0
        
        // loop over feedbackdata
        for x in feedbackData.keys {
            
            let page = feedbackData[x]?["page"] as! Int
            let feedback = feedbackData[x]?["feedback"] as! String
            let studentCount = feedbackData[x]?["studentCount"] as? Int ?? 1
            
            // if feedback is valid and the page is equal to the current page
            if (feedback == "positive" || feedback == "negative") && page == self.currentPresentation?.currentPage {
                
                // add the feedback to the totals
                returnFeedback[feedback]! += 1
                total += studentCount
                count += 1
            }
        }
        
        // if studentcount vars are not zero calculate average
        if total != 0 && count != 0 {
            
            returnFeedback["studentCount"] = total / count
        }
        
        return returnFeedback
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        // when finished loading resize content and stop activityIndicator
        self.slideView.resizeWebContent()
        activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        // start activityIndicator
        activityIndicator.startAnimating()
    }

}
