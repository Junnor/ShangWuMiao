//
//  FindPasswordViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/15.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class FindPasswordViewController: UIViewController {
    
    @IBOutlet private weak var phoneTextField: UITextField!
    @IBOutlet private weak var codeTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var codeActivity: UIActivityIndicatorView!
    
    @IBOutlet private weak var promptLabel: UILabel!
    
    private var emailView: UIView!
    private var telephoneView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "找回密码"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction private func getCode() {
    }
    @IBAction private func telephoneSubmit() {
    }

    @IBAction private func emailSubmit() {
    }
    @objc private func tapAction() {
        self.phoneTextField.resignFirstResponder()
        self.codeTextField.resignFirstResponder()
    }

}
