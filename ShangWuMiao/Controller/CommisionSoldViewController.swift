//
//  CommisionSoldViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD
import WebKit

class CommisionSoldViewController: UIViewController, WKNavigationDelegate {

    private let delegateUrlString = "https://www.nyato.com/help/annouce_detail/63?apppage=1"
    
    private var indicator: UIActivityIndicatorView!
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: delegateUrlString)
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
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        indicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }
    
}
