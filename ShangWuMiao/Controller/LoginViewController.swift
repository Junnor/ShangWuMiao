//
//  LoginViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }
    @IBOutlet weak var unameTextfield: UITextField! {
        didSet {
            unameTextfield?.delegate = self
        }
    }
    @IBOutlet weak var passwordTextfield: UITextField! {
        didSet {
            passwordTextfield?.delegate = self
        }
    }
    @IBOutlet weak var loginButton: UIButton!

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultMaskType(.clear)

        // not elegant
        let itemAppearance = UIBarButtonItem.appearance()
        itemAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -100, vertical: -100), for: .default)
        // 从搜索结果返回的时候取消按钮回变成cleanColor
//        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.clear], for: UIControlState.normal)
//        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
    
        NotificationCenter.default.addObserver(self.scrollView,
                                               selector: #selector(self.scrollView.nyato_keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)

    }
    
    private var setedUI = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !setedUI {
            setedUI = true
            setUI()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helper
    
    @IBAction func login(_ sender: UIButton) {
        tapAction()
        
        print("###login")
        guard let uname = unameTextfield.text,
            let password = passwordTextfield.text else {
                SVProgressHUD.showError(withStatus: "账号或密码不能为空")
                return
        }

        let parameters = ["uname": uname,
                          "password": password]
        SVProgressHUD.show(withStatus: "登陆中...")
        User.login(parameters: parameters) { [weak self] success, info in
            SVProgressHUD.dismiss()
            SVProgressHUD.showInfo(withStatus: info)
            if success {
                self?.performSegue(withIdentifier: "login", sender: nil)
                nyato_storeOauthData()
            }
        }
        
    }
    
    @objc private func tapAction() {
        self.unameTextfield.resignFirstResponder()
        self.passwordTextfield.resignFirstResponder()
    }
    
    private var unameLeftImageView = UIImageView()
    private var passwordLeftImageView = UIImageView()
    private func setUI() {
        let height = self.unameTextfield.bounds.height
        let unameLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: height))
        let passwordLeftView = UIView(frame: unameLeftView.bounds)
        self.unameLeftImageView = UIImageView(image: #imageLiteral(resourceName: "ico-uname"))
        self.passwordLeftImageView = UIImageView(image: #imageLiteral(resourceName: "ico-pass"))
        unameLeftView.addSubview(unameLeftImageView)
        unameLeftImageView.center = unameLeftView.center
        passwordLeftView.addSubview(passwordLeftImageView)
        passwordLeftImageView.center = passwordLeftView.center

        self.unameTextfield?.leftView = unameLeftView
        self.unameTextfield?.leftViewMode = .always
        self.passwordTextfield?.leftView = passwordLeftView
        self.passwordTextfield?.leftViewMode = .always
    }
    

    // MARK: - Text field delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == unameTextfield {
            unameLeftImageView.image = #imageLiteral(resourceName: "ico-uname")
        } else if textField == passwordTextfield {
            passwordLeftImageView.image = #imageLiteral(resourceName: "ico-pass")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == unameTextfield {
            unameLeftImageView.image = #imageLiteral(resourceName: "ico-unamed")
        } else if textField == passwordTextfield {
            passwordLeftImageView.image = #imageLiteral(resourceName: "ico-passed")
        }
    }
}

// MARK: - Keyboard action
//extension LoginViewController {
//    func keyboardNotification(notification: NSNotification) {
//        if let userInfo = notification.userInfo {
//            var endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
//            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
//            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
//            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
//            
//            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
//                let contentInset:UIEdgeInsets = UIEdgeInsets.zero
//                self.scrollView.contentInset = contentInset
//            } else {
//                endFrame = self.view.convert(endFrame!, from: nil)
//                var contentInset:UIEdgeInsets = self.scrollView.contentInset
//                contentInset.bottom = endFrame!.size.height
//                self.scrollView.contentInset = contentInset
//            }
//            
//            UIView.animate(withDuration: duration,
//                           delay: TimeInterval(0),
//                           options: animationCurve,
//                           animations: { self.view.layoutIfNeeded() },
//                           completion: nil)
//        }
//    }
    
//    fileprivate func isEmptyText(parse text: String?) -> Bool {
//        if text != nil {
//            let newText = text!.replacingOccurrences(of: " ", with: "")
//            return newText == "" ? true : false
//        }
//        return true
//    }
//}
