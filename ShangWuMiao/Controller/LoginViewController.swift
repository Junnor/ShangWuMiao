//
//  LoginViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var unameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // not elegant
        let itemAppearance = UIBarButtonItem.appearance()
        itemAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -100, vertical: -100), for: .default)
        // 从搜索结果返回的时候取消按钮回变成cleanColor
//        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.clear], for: UIControlState.normal)
//        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helper
    @IBAction func register() {
    }
    
    @IBAction func login(_ sender: UIButton) {
        let emptyUname = isEmptyText(parse: unameTextfield.text)
        if emptyUname {
            print("empty username")
            return
        }
        let emptyPassword = isEmptyText(parse: passwordTextfield.text)
        if emptyPassword {
            print("empty password")
            return
        }

        // test
        let parameters = ["uname": unameTextfield.text!,
                          "password": passwordTextfield.text!]
        User.login(parameters: parameters) { [weak self] status, info in
            if status == 1 {
                self?.performSegue(withIdentifier: "login", sender: nil)
                storeOauthData()
            } else {
                print("login failure: \(info)")
            }
        }
        
    }
    
    @objc private func tapAction() {
        self.unameTextfield.resignFirstResponder()
        self.passwordTextfield.resignFirstResponder()
    }
    
    private func setUI() {
//        let cornerRadius = self.unameTextfield.bounds.height/2
//        self.unameTextfield.layer.cornerRadius = cornerRadius
//        self.passwordTextfield.layer.cornerRadius = cornerRadius
//        self.loginButton.layer.cornerRadius = cornerRadius
        
        let height = self.unameTextfield.bounds.height
        let unameLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: height))
        let passwordLeftView = UIView(frame: unameLeftView.bounds)
        let unameLeftImageView = UIImageView(image: UIImage(named: "ico-uname"))
        let passwordLeftImageView = UIImageView(image: UIImage(named: "ico-pass"))
        unameLeftView.addSubview(unameLeftImageView)
        unameLeftImageView.center = unameLeftView.center
        passwordLeftView.addSubview(passwordLeftImageView)
        passwordLeftImageView.center = passwordLeftView.center

        self.unameTextfield.leftView = unameLeftView
        self.unameTextfield.leftViewMode = .always
        self.passwordTextfield.leftView = passwordLeftView
        self.passwordTextfield.leftViewMode = .always
    }
    
}

// MARK: - Keyboard action
extension LoginViewController {
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.view.frame.origin.y = 0
            } else {
                self.view.frame.origin.y = -50
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    fileprivate func isEmptyText(parse text: String?) -> Bool {
        if text != nil {
            let newText = text!.replacingOccurrences(of: " ", with: "")
            return newText == "" ? true : false
        }
        return true
    }
}
