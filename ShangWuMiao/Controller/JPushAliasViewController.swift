//
//  JPushAliasViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/20.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class JPushAliasViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(taptap))
        view.addGestureRecognizer(tap)
    }
    
    func taptap() {
        aliasTextField.resignFirstResponder()
    }

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var aliasTextField: UITextField!

    
    @IBAction func btnTouchUp(_ sender: AnyObject) {
        taptap()
        
        let alias = aliasTextField.text
        JPUSHService.setAlias(alias,
                              callbackSelector: #selector(tagsAliasCallBack(resCode:tags:alias:)),
                              object: self)
    }
    
    func tagsAliasCallBack(resCode: CInt, tags: NSSet, alias: NSString) {
        resultLabel.text = "响应结果：\(resCode)"
    }

}
