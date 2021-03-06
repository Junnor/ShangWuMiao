//
//  BindPhoneViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/16.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

class BindPhoneViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }
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
    
    // Corner view
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterView: CornerView!

    fileprivate var tableView: UITableView!
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "绑定手机"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self.scrollView,
                                               selector: #selector(self.scrollView.nyato_keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        
        filterLabel.text = "内地"
        
        configureTableView()
    }
    
    private var animatedTableViewFrame: CGRect = .zero
    private var beginingTableViewFrame: CGRect = .zero
    private func configureTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50

        var frame = filterView.frame
        frame.origin.y = frame.origin.y + frame.height + 10
        frame.size.height = CGFloat(AreaCodePlace.count * 50)
        
        animatedTableViewFrame = frame
        
        // For begining state
        frame.size.height = 0.0
        beginingTableViewFrame = frame
        
        tableView.frame = beginingTableViewFrame
        
        scrollView.addSubview(tableView)
        
        // Due to tableview has wried effect when in scrollview, so just add a gesture to tableview
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tableViewGesture(sender:))))
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helper
    
    fileprivate enum AreaCodePlace: Int {
        case mainland = 0
        case hongkong
        case macao
        case taiwang
        case japan
        case american
        
        static var count: Int { return 6 }
        
        var areaCode: String {
            
            for phone in User.shared.phonesInfo {
                if phone.title == self.name {
                    return phone.area_code
                }
            }
            return "1000"
        }
        
        var name: String {
            switch self {
            case .mainland: return "内地"
            case .hongkong: return "香港"
            case .macao: return "澳门"
            case .taiwang: return "台湾"
            case .japan: return "日本"
            case .american: return "美国"
            }
        }
    }
    
    fileprivate var selectedPlace: AreaCodePlace = .mainland {
        didSet {
            filterLabel.text = selectedPlace.name
        }
    }
    
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
                User.requestPhoneCode(for: phoneTextField.text!,
                                      codeType: GetCodeType.register,
                                      areaCode: selectedPlace.areaCode) {
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


    @IBAction func submit(_ sender: Any) {
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
        
        self.timer.invalidate()
        
        User.bindTelephone(codePhone, code: code) { (success, info) in
            SVProgressHUD.showInfo(withStatus: info)
            if success {
                User.shared.telephone = self.codePhone
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    private let duration: TimeInterval = 0.2
    @objc private func tableViewGesture(sender: UIGestureRecognizer) {
        let location = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: location) {
            selectedPlace = AreaCodePlace(rawValue: indexPath.row)!
            
            UIView.animate(withDuration: duration, animations: {
                self.tableView.frame = self.beginingTableViewFrame
            })
            UIView.animate(withDuration: duration, animations: {
                self.tableView.frame = self.beginingTableViewFrame
            }, completion: { (_) in
                self.placeSelected = false
                self.tableView.reloadData()  // for cell.textColor
            })
        }
    }

    private var placeSelected = false {
        didSet {
            filterLabel.textColor = placeSelected ? UIColor.themeYellow : UIColor.mainTextColor
            filterImageView.image = placeSelected ? #imageLiteral(resourceName: "ico-filter-yellow") : #imageLiteral(resourceName: "ico-filter-gray")
        }
    }
    @IBAction func filterAction(_ sender: UIButton) {
        placeSelected = !placeSelected
        
        UIView.animate(withDuration: duration, animations: {
            self.tableView.frame = self.placeSelected ?
                self.animatedTableViewFrame : self.beginingTableViewFrame
        })
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

extension BindPhoneViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AreaCodePlace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let palce = AreaCodePlace(rawValue: indexPath.row)
        cell?.textLabel?.text = palce?.name
        cell?.textLabel?.textColor = selectedPlace == AreaCodePlace(rawValue: indexPath.row) ?
            UIColor.themeYellow : UIColor.mainTextColor
        return cell!
    }
}
