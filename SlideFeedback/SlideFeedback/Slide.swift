//
//  Slide.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 15-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import Foundation

struct Slide {
    
    // all vars needed for a slideshow
    var dirName: String
    var name: String
    var numPages: Int
    var currentPage: Int
    var timeStamp: String
    var uniqueID: String
    let baseUrl = "http://app.thomaskamps.nl:8080/static/uploads/"
    
    init(data: [String: Any]) {
        
        // on init set vars from dictionary
        self.dirName = data["dirName"] as! String
        self.name = data["name"] as! String
        self.currentPage = data["currentPage"] as! Int
        self.numPages = data["numPages"] as! Int
        self.timeStamp = data["timestamp"] as! String
        self.uniqueID = data["unique_id"] as! String
    }
    
    func buildUrlString() -> String {
        
        // build the url for the current page
        let urlString = self.baseUrl + self.dirName + "/" + String(self.currentPage) + ".pdf"
        return urlString
    }
}
