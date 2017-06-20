//
//  WebViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/20.
//  Copyright © 2017年 moelove. All rights reserved.
//


import UIKit
import SVProgressHUD
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var url: URL!
    var webTitle: String!
    
    private var indicator: UIActivityIndicatorView!
    private var webView: WKWebView!
    
    private var loaded = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !loaded {
            loaded = true
            
            if let webTitle = webTitle {
                title = webTitle
            }
            
            let reuqest = URLRequest(url: url!)
            
            var frame = self.view.frame
            frame.origin.y = 64
            frame.size.height = frame.height - 64
            
            webView = WKWebView(frame: frame)
            webView.navigationDelegate = self
            webView.load(reuqest)
            view.addSubview(webView)
            
            indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.center = webView.center
            indicator.startAnimating()
            view.addSubview(indicator)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        indicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }
    
}

