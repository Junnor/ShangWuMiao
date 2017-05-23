//
//  RegisterNameViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/23.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class RegisterNameViewController: UIViewController {

    @IBOutlet weak var unameTextField: CornerTextField!
    @IBOutlet weak var passwordTextField: CornerTextField!
    @IBOutlet weak var verifyTextField: CornerTextField!
    
    @IBAction func complete() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapAction() {
        self.unameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.verifyTextField.resignFirstResponder()
    }
}
