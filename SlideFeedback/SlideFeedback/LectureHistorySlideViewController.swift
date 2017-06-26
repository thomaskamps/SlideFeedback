//
//  LectureHistorySlideViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 22-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class LectureHistorySlideViewController: UIViewController, UIWebViewDelegate {

    
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
        let feedback = db.history[(self.currentPresentation?.uniqueID)!]?["feedback"] as! [String: Any]
        if let feedbackNew = feedback[String(describing: self.currentPresentation?.currentPage)] as? [String: Any]{
            print(feedbackNew)
            let negative = feedbackNew["negative"] ?? 0
            let positive = feedbackNew["positive"] ?? 0
            let feedbackString = "Feedback: " + String(describing: positive) + " positive, " + String(describing: negative) + " negative."
            self.feedbackLabel.text = feedbackString
        } else {
            let feedbackString = "No feedback"
            self.feedbackLabel.text = feedbackString
        }
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        self.slideView.resizeWebContent()
        activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        activityIndicator.startAnimating()
    }

}
