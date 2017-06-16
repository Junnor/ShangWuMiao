//
//  FeedbackViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

class FeedbackViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
    
    @IBOutlet weak var publishButton: UIButton!
    
    @IBAction func publish() {

        if textView.text == promptText {
            return
        }
        
        let text = textView.text
        
        User.feedbackWithContent(contentText: text!) { [weak self] _, info in
            self?.textView.resignFirstResponder()
            
            SVProgressHUD.showInfo(withStatus: info)
        }
    }
    private let promptText = "请输入反馈内容(最多250个字)"
    private let maximumChars = 250
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "反馈"
        
        textView.text = promptText
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGessture)))
        
        setUIDetail()
    }
    
    private func setUIDetail() {
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        textView.layer.cornerRadius = 3.0
        textView.layer.masksToBounds = true
        
        textView.textColor = UIColor.lightGray
    }
    
    @objc private func tapGessture() {
        textView.resignFirstResponder()
    }
    
    // MARK: - Text view delegate
    
    private var isPlaceholderText = true
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if isPlaceholderText {
            isPlaceholderText = false
            self.textView.text = ""
            self.textView.textColor = UIColor.gray
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        if numberOfChars > maximumChars {
            SVProgressHUD.showInfo(withStatus: "反馈内容字数太多!")
        }
        return numberOfChars <= maximumChars
    }
    
}
