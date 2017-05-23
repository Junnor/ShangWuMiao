//
//  RegisterNameViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/23.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegisterNameViewController: UIViewController {
    
    var code: String!
    var phone: String!

    @IBOutlet weak var unameTextField: CornerTextField! 
    @IBOutlet weak var passwordTextField: CornerTextField!
    @IBOutlet weak var verifyTextField: CornerTextField!
    
    @IBAction func complete() {
        tapAction()
        
        guard let uname = unameTextField.text,
            let password = passwordTextField.text,
            let verified = verifyTextField.text,
            password == verified,
            7 <= password.characters.count,
            password.characters.count >= 16 else {
            return
        }
        
        if 3 < uname.characters.count || uname.characters.count < 10 {
            SVProgressHUD.showInfo(withStatus: "名称太短或太长")
            return
        }
        
        Login.register(forUser: unameTextField.text!,
                       password: passwordTextField.text!, mobile: phone, code: code) {
                        success, info in
                        if success {
                            // TODO: login
                            print("success info")
                        } else {
                            print("error info")
                        }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapAction() {
        self.unameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.verifyTextField.resignFirstResponder()
    }
}
