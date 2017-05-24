//
//  RegisterTelViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/23.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegisterTelViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var codeButton: CornerButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorView?.isHidden = true
        }
    }
    
    @IBOutlet weak var promptLable: UILabel! {
        didSet {
            promptLable?.text = "先输入手机号，点击“获取验证码”，\n然后输入手机收到的验证码点击下一步 "
        }
    }
    
    @IBOutlet weak var phoneTextField: CornerTextField! {
        didSet {
            phoneTextField.delegate = self
        }
    }
    @IBOutlet weak var codeTextField: CornerTextField! {
        didSet {
            code = codeTextField.text
        }
    }
    
    private var codePhone: String!
    private var submitPhone: String!
    private var code: String!
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "注册"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
    }
    
    private var hasLeftImage = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !hasLeftImage {
            hasLeftImage = false
            setUI()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetInfo()
    }
    
    // MARK: - Helper
    @IBAction func getCode() {
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
                Login.requestPhoneCode(for: phoneTextField.text!) {
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
    
    @IBAction func submit() {
        tapAction()
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
        
        self.timer.invalidate()
        performSegue(withIdentifier: "register", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "register" {
            if let vc = segue.destination as? RegisterNameViewController {
                vc.code = code
                vc.phone = codePhone
                vc.title = "设置账户信息"
            }
        }
    }
    
    // two image states for leftImageView
    private var leftImageView = UIImageView()
    private func setUI() {
        let height = self.phoneTextField.bounds.height
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: height))
        self.leftImageView = UIImageView(image: #imageLiteral(resourceName: "ico-phone"))
        leftView.addSubview(self.leftImageView)
        leftImageView.center = leftView.center
        
        self.phoneTextField.leftView = leftView
        self.phoneTextField.leftViewMode = .always
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
    
    @objc private func tapAction() {
        self.phoneTextField.resignFirstResponder()
        self.codeTextField.resignFirstResponder()
    }
    
    // MARK: - Text field delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phoneTextField {
            leftImageView.image = #imageLiteral(resourceName: "ico-phone")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneTextField {
            leftImageView.image = #imageLiteral(resourceName: "ico-phoned")
        }
    }

}
