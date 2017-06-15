//
//  ResetPasswordViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/15.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    var code: String!

    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }
    
    @IBOutlet private weak var passwordTextField: CornerTextField! {
        didSet {
            passwordTextField?.delegate = self
        }
    }
    
    @IBOutlet private weak var verifyTextField: CornerTextField! {
        didSet {
            verifyTextField?.delegate = self
        }
    }

    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "修改密码"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        
        NotificationCenter.default.addObserver(self.scrollView,
                                               selector: #selector(self.scrollView.nyato_keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Helper
    
    @IBAction func complete() {
        tapAction()
        
        guard let password = passwordTextField.text,
            let verified = verifyTextField.text,
            password == verified,
            7 <= password.characters.count,
            password.characters.count <= 16 else {
                return
        }
        
        let uname = "xxxxxxxxxxxx"
        let phone = "xxxxxxxxxxxx"
        
        User.register(forUser: uname,
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    
    @objc private func tapAction() {
        self.passwordTextField.resignFirstResponder()
        self.verifyTextField.resignFirstResponder()
    }
}
