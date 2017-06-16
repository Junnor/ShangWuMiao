//
//  BindPhoneViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/16.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class BindPhoneViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }
    @IBOutlet weak var codeButton: CornerButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorView?.isHidden = true
        }
    }
    
    @IBOutlet weak var promptLable: UILabel! {
        didSet {
            promptLable?.text = "先输入手机号，点击“获取验证码”，\n然后输入手机收到的验证码点击下一步 "
        }
    }
    
    @IBOutlet weak var phoneTextField: CornerTextField! {
        didSet {
            phoneTextField.delegate = self
        }
    }
    @IBOutlet weak var codeTextField: CornerTextField! {
        didSet {
            code = codeTextField.text
        }
    }
    
    private var codePhone: String!
    private var submitPhone: String!
    private var code: String!
    
    // Corner view
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "绑定手机"
    }

    @IBAction func submit(_ sender: Any) {
    }

    @IBAction func filterAction(_ sender: UIButton) {
    }
}
