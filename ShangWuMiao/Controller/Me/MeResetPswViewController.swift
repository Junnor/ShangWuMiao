//
//  MeResetPswViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/16.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

class MeResetPswViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }
    
    @IBOutlet weak var originalPswTextField: CornerTextField! {
        didSet {
            originalPswTextField?.delegate = self
        }
    }
    @IBOutlet weak var newPswTextField: CornerTextField! {
        didSet {
            newPswTextField?.delegate = self
        }
    }
    
    @IBOutlet weak var repeatPswTextField: CornerTextField! {
        didSet {
            repeatPswTextField?.delegate = self
        }
    }
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        
        title = "修改密码"

        super.viewDidLoad()
        
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
    
    @IBAction func submit(_ sender: Any) {
        tapAction()
        
        guard let original = originalPswTextField.text,
            let password = newPswTextField.text,
            let repassword = repeatPswTextField.text,
            original != "", password != "", repassword != "" else {
                return
        }

        if password != repassword {
            SVProgressHUD.showInfo(withStatus: "两次密码不一下")
            return
        }
        
        if !(7 <= password.characters.count && password.characters.count <= 16) {
            SVProgressHUD.showInfo(withStatus: "密码长度不符合规范")
            return
        }
        
        User.meResetPassword(password,
                             repassword: repassword,
                             original: original) { (success, info) in
                                SVProgressHUD.showInfo(withStatus: info)
                                if success {
                                    self.navigationController?.popViewController(animated: true)
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
        self.originalPswTextField.resignFirstResponder()
        self.newPswTextField.resignFirstResponder()
        self.repeatPswTextField.resignFirstResponder()
    }

}
