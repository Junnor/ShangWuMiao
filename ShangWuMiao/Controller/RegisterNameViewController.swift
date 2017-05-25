//
//  RegisterNameViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/23.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegisterNameViewController: UIViewController, UITextFieldDelegate {
    
    var code: String!
    var phone: String!

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }

    @IBOutlet weak var unameTextField: CornerTextField! {
        didSet {
            unameTextField?.delegate = self
        }
    }
    @IBOutlet weak var passwordTextField: CornerTextField! {
        didSet {
            passwordTextField?.delegate = self
        }
    }

    @IBOutlet weak var verifyTextField: CornerTextField! {
        didSet {
            verifyTextField?.delegate = self
        }
    }
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
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
        self.unameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.verifyTextField.resignFirstResponder()
    }
}
