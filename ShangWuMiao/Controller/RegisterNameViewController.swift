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

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }

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
            password.characters.count <= 16 else {
            return
        }
        
        Login.register(forUser: uname,
                       password: password, mobile: phone, code: code) {
                        [weak self] success, info in
                        SVProgressHUD.showInfo(withStatus: info)
                        if success {
                            if self != nil {
                                self?.performSegue(withIdentifier: "login from register", sender: nil)
                                nyato_storeOauthData()
                            }
                        } else {
                            SVProgressHUD.showError(withStatus: info)
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
