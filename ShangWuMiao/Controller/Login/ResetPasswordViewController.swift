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
    
    var phone: String!
    
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
            password == verified, password != "" else {
                SVProgressHUD.showInfo(withStatus: "密码不一致")
                return
        }
        
        guard 7 <= password.characters.count,
            password.characters.count <= 16 else {
                SVProgressHUD.showInfo(withStatus: "密码7到16位")
                return
        }
        
        User.resetPassword(by: phone,
                           password: password,
                           repeatPassword: verified) { (success, info) in
                            if success {
                                SVProgressHUD.showSuccess(withStatus: info)
                                self.navigationController?.popViewController(animated: true)
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
