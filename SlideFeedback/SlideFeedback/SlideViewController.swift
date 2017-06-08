//
//  SlideViewController.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 07-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import UIKit

class SlideViewController: UIViewController, UIWebViewDelegate {

    @IBAction func previousButton(_ sender: Any) {
        if currentPage > 0 {
            currentPage -= 1
            slideViewLoad(urlString: buildUrlString(page: currentPage))
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
        if currentPage < numPages {
            currentPage += 1
            slideViewLoad(urlString: buildUrlString(page: currentPage))
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slideView: UIWebView!
    
    var dirName = "3c10aeee-4a5b-4dd8-adb3-4b10836afa72"
    var numPages = 100
    let baseUrl = "http://app.thomaskamps.nl/static/uploads/"
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.slideView.delegate = self
        slideViewLoad(urlString: buildUrlString(page: currentPage))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buildUrlString(page: Int) -> String {
        let urlString = baseUrl+dirName+"/"+String(currentPage)+".pdf"
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
