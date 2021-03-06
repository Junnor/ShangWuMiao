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
        
        // 是否显示引导页
        UserDefaults.standard.setValue(1, forKey: installOrReinstall)
        
//        // 定位相关
//        _ = LocationViewController()
        
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
                JPUSHService.setAlias("\(User.shared.uid)", callbackSelector: nil, object: nil)

                self?.performSegue(withIdentifier: "login", sender: nil)
                nyato_storeOauthData()
            }
        }
        
    }
    
    @IBAction func findPassword() {
        performSegue(withIdentifier: "findPassword", sender: self)
    }
    
    @IBAction func register() {
        performSegue(withIdentifier: "registerNow", sender: self)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
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
