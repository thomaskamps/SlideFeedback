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
        if self.currentPage! < self.numPages! {
            self.currentPage! += 1
            slideViewLoad(urlString: buildUrlString(page: currentPage!))
            sio.changePage(currentPage: currentPage!)
        }
    }
    
    @IBAction func previousButton(_ sender: Any) {
        if self.currentPage! > 0 {
            self.currentPage! -= 1
            slideViewLoad(urlString: buildUrlString(page: currentPage!))
            sio.changePage(currentPage: currentPage!)
        }
    }
    
    @IBAction func endSlideButton(_ sender: Any) {
        sio.endLecture()
    }
    
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
            sio.claimLecture(room: name!)
            slideViewLoad(urlString: buildUrlString(page: currentPage!))
            NotificationCenter.default.addObserver(self, selector: #selector(self.endLecture(notification:)), name: Notification.Name("newRooms"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNegativeFeedback(notification:)), name: Notification.Name("receiveNegativeFeedback"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.receivePositiveFeedback(notification:)), name: Notification.Name("receivePositiveFeedback"), object: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*override func viewDidDisappear(_ animated: Bool) {
        if name != nil {
            sio.leaveRoom(room: name!)
        }
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    func endLecture(notification: Notification) {
        self.performSegue(withIdentifier: "endSlideSegue", sender: nil)
    }
    
    func receiveNegativeFeedback(notification: Notification) {
        self.alert(title: "You received feedback", message: "Unfortunately it is negative")
    }
    
    func receivePositiveFeedback(notification: Notification) {
        self.alert(title: "You received feedback", message: "Yeah it is positive")
    }

}
