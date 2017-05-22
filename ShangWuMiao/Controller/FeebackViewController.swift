//
//  FeebackViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class FeebackViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
    
    @IBOutlet weak var publishButton: UIButton!
    
    @IBAction func publish() {
        
        let text = textView.text
        User.feedbackWithContent(contentText: text!) { success, info in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "反馈"
        
        textView.text = "请输入反馈内容(最多250个字)"
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGessture)))
        
        setUIDetail()
    }
    
    private func setUIDetail() {
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        textView.layer.cornerRadius = 3.0
        textView.layer.masksToBounds = true
        
        textView.textColor = UIColor.lightGray
        
        publishButton.layer.cornerRadius = publishButton.bounds.height / 2
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
        
        return true
    }
    
}
