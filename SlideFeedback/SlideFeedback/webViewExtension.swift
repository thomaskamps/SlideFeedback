//
//  File.swift
//  SlideFeedback
//
//  Created by Thomas Kamps on 07-06-17.
//  Copyright © 2017 Thomas Kamps. All rights reserved.
//

import Foundation
import UIKit

extension UIWebView {
    ///Method to fit content of webview inside webview according to different screen size
    func resizeWebContent() {
        let contentSize = self.scrollView.contentSize
        let viewSize = self.bounds.size
        let zoomScale = viewSize.height/contentSize.height
        
        let marginLeft = (viewSize.width - contentSize.width*zoomScale) / 2
        self.scrollView.contentInset = UIEdgeInsets(top: 0,left: marginLeft,bottom: 0,right: 0)
        
        self.scrollView.minimumZoomScale = zoomScale
        self.scrollView.maximumZoomScale = zoomScale
        self.scrollView.zoomScale = zoomScale
    }
}
