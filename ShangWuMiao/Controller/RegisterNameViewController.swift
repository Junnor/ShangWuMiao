//
//  RegisterNameViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/23.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class RegisterNameViewController: UIViewController {
    
    var code: String!
    var phone: String!

    @IBOutlet weak var unameTextField: CornerTextField!
    @IBOutlet weak var passwordTextField: CornerTextField!
    @IBOutlet weak var verifyTextField: CornerTextField!
    
    @IBAction func complete() {
        tapAction()
        
        Login.register(forUser: unameTextField.text!,
                       password: passwordTextField.text!, mobile: phone, code: code) {
                        [weak self] success, info in
                        if success {
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
