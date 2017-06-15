//
//  Slide.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 15-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import Foundation

struct Slide {
    
    var dirName: String
    var name: String
    var numPages: Int
    var currentPage: Int
    let baseUrl = "http://app.thomaskamps.nl:8080/static/uploads/"
    
    init(data: [String: Any]) {
        
        self.dirName = data["dirName"] as! String
        self.name = data["name"] as! String
        self.currentPage = data["currentPage"] as! Int
        self.numPages = data["numPages"] as! Int
    }
    
    func buildUrlString() -> String {
        
        let urlString = self.baseUrl + self.dirName + "/" + String(self.currentPage) + ".pdf"
        return urlString
    }
}
