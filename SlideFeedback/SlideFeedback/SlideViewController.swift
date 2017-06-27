//
//  SlideViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 07-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class SlideViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slideView: UIWebView!
    @IBOutlet weak var negativeFeedbackButton: UIButton!
    @IBOutlet weak var positiveFeedbackButton: UIButton!
    
    let sio = SocketIOManager.sharedInstance
    let db = FirebaseManager.sharedInstance
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.slideView.delegate = self
        
        if sio.currentRoom != nil {
            
            db.startSlides(dirName: (sio.currentRoom?.dirName)!, uniqueID: (sio.currentRoom?.uniqueID)!, timeStamp: (sio.currentRoom?.timeStamp)!, name: (sio.currentRoom?.name)!, numPages: (sio.currentRoom?.numPages)!)
            slideViewLoad(urlString: (sio.currentRoom?.buildUrlString())!)
            NotificationCenter.default.addObserver(self, selector: #selector(self.changePage(notification:)), name: Notification.Name("changePage"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.endSlides(notification:)), name: Notification.Name("endSlides"), object: nil)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if sio.currentRoom != nil {
            
            sio.leaveRoom()
        }
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
    
    func changePage(notification: Notification) {
        
        slideViewLoad(urlString: (sio.currentRoom?.buildUrlString())!)
        negativeFeedbackButton.isEnabled = true
        positiveFeedbackButton.isEnabled = true
    }
    
    @IBAction func negativeFeedbackAction(_ sender: Any) {
        
        negativeFeedbackButton.isEnabled = false
        positiveFeedbackButton.isEnabled = false
        db.saveFeedback(uniqueID: (sio.currentRoom?.uniqueID)!, currentPage: (sio.currentRoom?.currentPage)!, feedback: "negative", studentCount: nil)
        
        sio.sendFeedback(feedback: "negative")
    }
    
    @IBAction func positiveFeedbackAction(_ sender: Any) {
        
        negativeFeedbackButton.isEnabled = false
        positiveFeedbackButton.isEnabled = false
        db.saveFeedback(uniqueID: (sio.currentRoom?.uniqueID)!, currentPage: (sio.currentRoom?.currentPage)!, feedback: "positive", studentCount: nil)
        
        sio.sendFeedback(feedback: "positive")
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func endSlides(notification: Notification) {
        
        let alert = UIAlertController(title: "Lecture has been ended", message: "You will now be brought back to the overview", preferredStyle: .alert)
        let oke = UIAlertAction(title: "Oke", style: .default, handler: {(action) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(oke)
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
