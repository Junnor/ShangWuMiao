//
//  RegisterTelViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/23.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class RegisterTelViewController: UIViewController {


    @IBOutlet weak var promptLable: UILabel! {
        didSet {
            promptLable?.text = "先输入手机号，点击“获取验证码”，\n然后输入手机收到的验证码点击下一步 "
        }
    }
    
    @IBOutlet weak var phoneTextField: CornerTextField!
    
    @IBOutlet weak var codeTextField: CornerTextField!
    
    @IBAction func getCode() {
    }
    
    @IBAction func submit() {
        performSegue(withIdentifier: "register", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapAction() {
        self.phoneTextField.resignFirstResponder()
        self.codeTextField.resignFirstResponder()
    }

}
