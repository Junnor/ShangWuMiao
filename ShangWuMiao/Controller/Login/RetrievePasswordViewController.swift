//
//  RetrievePasswordViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/15.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

class RetrievePasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var phoneTextField: UITextField! {
        didSet {
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet private weak var codeTextField: UITextField! {
        didSet {
            code = codeTextField.text
        }
    }

    @IBOutlet private weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorView?.isHidden = true
        }
    }
    
    @IBOutlet private weak var codeButton: UIButton!
    @IBOutlet private weak var promptLabel: UILabel!
    @IBOutlet private weak var telephoneBar: UIView!
    @IBOutlet private weak var emailBar: UIView!

    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }

    @IBOutlet private weak var containerView: UIView!
    
    private var emailView: UIView!
    private var telephoneView: UIView!

    private var codePhone: String!
    private var code: String!
    
    private enum PromptType: String {
        case telephone = "先输入手机号，点击“获取验证码”，然后输入手机收到的验证码点击下一步 "
        case email = "请输入注册时填写的邮箱，完成找回密码后，建议绑定手机号码"
    }

    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "找回密码"
        
        promptLabel?.text = PromptType.telephone.rawValue
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        
        NotificationCenter.default.addObserver(self.scrollView,
                                               selector: #selector(self.scrollView.nyato_keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        telephoneView = UINib(nibName: "FindPasswordWithTelephone", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        emailView = UINib(nibName: "FindPasswordWithEmail", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        
        telephoneView.isHidden = false
        emailView.isHidden = true
        
        telephoneBar.isHidden = telephoneView.isHidden
        emailBar.isHidden = emailView.isHidden
        
        containerView.addSubview(telephoneView)
        containerView.addSubview(emailView)
        
        containerView.backgroundColor = UIColor.clear
    }
    
    private var hasLeftImage = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !hasLeftImage {
            hasLeftImage = false
            
            var containerViewBounds = view.bounds
            containerViewBounds.size.height = 300
            telephoneView.frame = containerViewBounds
            emailView.frame = containerViewBounds
            
            setLeftImage()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetInfo()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helper
    
    @IBAction func findPasswordType(_ sender: UIButton) {
        if let text = sender.currentTitle, text == "手机找回" {
            promptLabel.text = PromptType.telephone.rawValue
            telephoneView.isHidden = false
            emailView.isHidden = true
            
            telephoneBar.isHidden = telephoneView.isHidden
            emailBar.isHidden = emailView.isHidden
        } else {
            promptLabel.text = PromptType.email.rawValue
            telephoneView.isHidden = true
            emailView.isHidden = false
            
            telephoneBar.isHidden = telephoneView.isHidden
            emailBar.isHidden = emailView.isHidden
        }
    }
    
    @IBAction private func getCode() {
        if phoneTextField?.text?.characters.count != 0 {
            let response = nyato_isPhoneNumber(phoneNumber: phoneTextField?.text)
            if response.result == false {
                // 解决SVProgressHUD 在有键盘时不居中的bug
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    SVProgressHUD.showInfo(withStatus: response.info!)
                })
            } else {
                self.indicatorView.isHidden = false
                self.indicatorView.startAnimating()
                User.requestPhoneCode(for: phoneTextField.text!,
                                      codeType: GetCodeType.retrievePassword,
                                      hasAreaCode: false) {
                    [weak self] (success, info) in
                    SVProgressHUD.showInfo(withStatus: info)
                    if success {
                        if self != nil {
                            self?.codePhone = self?.phoneTextField.text
                            self?.fireTimer()
                        }
                    } else {
                        self?.indicatorView.stopAnimating()
                    }
                }
            }
        }
    }
    
    @IBAction private func telephoneSubmit() {
        tapAction()
        if codePhone == nil {
            return
        }
        
        guard let phone = phoneTextField.text, codePhone != nil, phone == codePhone else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                SVProgressHUD.showInfo(withStatus: "请勿更改手机号")
            })
            return
        }
        
        code = codeTextField?.text
        
        if code == nil || code == "" {
            return
        }
        
        
        User.verifyCodeForRetrievePswPhone(codePhone, verifyCode: code) { [weak self] (success, info) in
            SVProgressHUD.showInfo(withStatus: info)
            self?.timer.invalidate()
            if success {
                self?.performSegue(withIdentifier: "resetPassword", sender: nil)
            }
        }
    }

    @IBAction private func emailSubmit() {
        if let email = emailTextField.text, email != "" {
            User.retrievePasswordWithEmail(email, completionHandler: { (success, info) in
                if success {
                    SVProgressHUD.showSuccess(withStatus: info)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    SVProgressHUD.showError(withStatus: info)
                }
            })
        }
    }
    
    @objc private func tapAction() {
        self.phoneTextField.resignFirstResponder()
        self.codeTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resetPassword" {
            if let vc = segue.destination as? ResetPasswordViewController {
                vc.phone = codePhone
            }
        }
    }
    
    // two image states for leftImageView
    private var telephoneLeftImageView = UIImageView()
    private var emailLeftImageView = UIImageView()
    private func setLeftImage() {
        // for telephone
        let height = self.phoneTextField.bounds.height
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: height))
        self.telephoneLeftImageView = UIImageView(image: #imageLiteral(resourceName: "ico-phone"))
        leftView.addSubview(self.telephoneLeftImageView)
        telephoneLeftImageView.center = leftView.center
        
        self.phoneTextField.leftView = leftView
        self.phoneTextField.leftViewMode = .always
        
        // For email
        let emialHeight = self.emailTextField.bounds.height
        let emailLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: emialHeight))
        self.emailLeftImageView = UIImageView(image: #imageLiteral(resourceName: "ico-email"))
        emailLeftView.addSubview(self.emailLeftImageView)
        emailLeftImageView.center = emailLeftView.center
        
        self.emailTextField.leftView = emailLeftView
        self.emailTextField.leftViewMode = .always
    }
    
    private var seconds = 60;
    private var timer = Timer()
    // Used fireTimer(), instead of timer.fire(), because timer may remove from the runloop
    private func fireTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                          target: self,
                                          selector: #selector(self.requestCodeAgain),
                                          userInfo: nil,
                                          repeats: true)
        self.timer.fire()
    }
    
    private func resetInfo() {
        self.seconds = 60
        self.timer.invalidate()
        self.indicatorView.stopAnimating()
        self.codeButton.setTitle("获取验证码", for: .normal)
    }
    
    @objc private func requestCodeAgain() {
        self.seconds -= 1
        self.codeButton.setTitle("重新获取\(self.seconds)秒", for: .normal)
        
        if self.seconds == 0 {
            resetInfo()
        }
    }
        
    // MARK: - Text field delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phoneTextField {
            telephoneLeftImageView.image = #imageLiteral(resourceName: "ico-phone")
        } else if textField == emailTextField {
            emailLeftImageView.image = #imageLiteral(resourceName: "ico-email")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneTextField {
            telephoneLeftImageView.image = #imageLiteral(resourceName: "ico-phoned")
        } else if textField == emailTextField {
            emailLeftImageView.image = #imageLiteral(resourceName: "ico-emailed")
        }

    }
}
