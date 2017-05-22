//
//  CommisionSoldViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

private let delegateUrlString = "https://www.nyato.com/help/annouce_detail/63?apppage=1"

import UIKit
import SVProgressHUD

class CommisionSoldViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nyato喵特网 - 有爱、贴心、便捷的漫展服务平台 -"
        
        let url = URL(string: delegateUrlString)
        let reuqest = URLRequest(url: url!)
        webView.loadRequest(reuqest)
    }
    
    // MARK: - Delegate
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        SVProgressHUD.showError(withStatus: "请求失败，请重新加载")
    }
    
}
