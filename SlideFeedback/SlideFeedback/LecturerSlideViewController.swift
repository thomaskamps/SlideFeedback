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
        
        db.saveFeedback(uniqueID: (sio.currentRoom?.uniqueID)!, currentPage: (sio.currentRoom?.currentPage)!, feedback: "negative")
        self.alert(title: "You received feedback", message: "Unfortunately it is negative")
    }
    
    func receivePositiveFeedback(notification: Notification) {
        
        db.saveFeedback(uniqueID: (sio.currentRoom?.uniqueID)!, currentPage: (sio.currentRoom?.currentPage)!, feedback: "positive")
        self.alert(title: "You received feedback", message: "Yeah it is positive")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
