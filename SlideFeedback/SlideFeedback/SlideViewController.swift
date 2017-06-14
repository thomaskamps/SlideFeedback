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

    var dirName: String?
    var numPages: Int?
    let baseUrl = "http://app.thomaskamps.nl:8080/static/uploads/"
    var currentPage: Int?
    var name: String?
    
    let sio = SocketIOManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.slideView.delegate = self
        
        if dirName != nil && numPages != nil && currentPage != nil {
            slideViewLoad(urlString: buildUrlString(page: currentPage!))
        }
        
        if name != nil {
            sio.joinRoom(room: name!)
            NotificationCenter.default.addObserver(self, selector: #selector(self.changePage(notification:)), name: Notification.Name("changePage"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.endSlides(notification:)), name: Notification.Name("endSlides"), object: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if name != nil {
            sio.leaveRoom(room: name!)
        }
    }
    
    func buildUrlString(page: Int) -> String {
        let urlString = baseUrl+dirName!+"/"+String(page)+".pdf"
        print(urlString)
        return urlString
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
        if let temp = sio.rooms?[self.name!]?["currentPage"] {
            self.currentPage = temp as! Int
            slideViewLoad(urlString: buildUrlString(page: currentPage!))
            negativeFeedbackButton.isEnabled = true
            positiveFeedbackButton.isEnabled = true
            
        }
    }
    
    @IBAction func negativeFeedbackAction(_ sender: Any) {
        negativeFeedbackButton.isEnabled = false
        positiveFeedbackButton.isEnabled = false
        
        sio.sendFeedback(feedback: "negative", room: name!)
    }
    
    @IBAction func positiveFeedbackAction(_ sender: Any) {
        negativeFeedbackButton.isEnabled = false
        positiveFeedbackButton.isEnabled = false
        
        sio.sendFeedback(feedback: "positive", room: name!)
    }
    
    func endSlides(notification: Notification) {
        let alert = UIAlertController(title: "Lecture has been ended", message: "You will now be brought back to the overview", preferredStyle: .alert)
        let oke = UIAlertAction(title: "Oke", style: .default, handler: {(action) -> Void in
            self.performSegue(withIdentifier: "endSlideStudent", sender: nil)
        })
        alert.addAction(oke)
        self.present(alert, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
