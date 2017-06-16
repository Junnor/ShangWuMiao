//
//  WalletViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/5.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import PassKit

class WalletViewController: UIViewController {
    
    // Get throught webservice..... must not be nil
    private var receivedPassData: Data!

    @IBOutlet weak var addPassButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addPassButton.addTarget(self, action: #selector(addPass), for: .touchUpInside)
        
        isUseableCheck()
    }
    
    // For test
    @objc private func addPass() {
        DispatchQueue.main.async {
            let activity = UIActivityViewController(activityItems: ["I love it!"],
                                                    applicationActivities: nil)
            self.present(activity, animated: true, completion: nil)
        }
    }
    
//    @objc private func addPass() {
//        // Test receivedPassData
//        let filePath = Bundle.main.path(forResource: "Lollipop", ofType: "pkpass")
//        receivedPassData = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
//
//        var error: NSError?
//        let pass = PKPass(data: receivedPassData, error: &error)
//        
//        if error != nil {
//            let alert = UIAlertController(title: "Pass error",
//                                          message: error?.localizedDescription,
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
//            present(alert, animated: true, completion: nil)
//            return
//        }
//        
//        let passLibrary = PKPassLibrary()
//        if passLibrary.containsPass(pass) {
//            let alert = UIAlertController(title: "Wallet",
//                                          message: "您已添加该卡券",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
//            present(alert, animated: true, completion: nil)
//        } else {
//            let addPassViewController = PKAddPassesViewController(pass: pass)
//            addPassViewController.delegate = self
//            present(addPassViewController, animated: true, completion: nil)
//        }
//    }
    
    private func isUseableCheck() {
        if !PKPassLibrary.isPassLibraryAvailable() {
            let alert = UIAlertController(title: "Wallet",
                                          message: "工具包不存在",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        if !PKAddPassesViewController.canAddPasses() {
            let alert = UIAlertController(title: "Wallet",
                                          message: "该设备不支持添加到Wallet",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

}

extension WalletViewController: PKAddPassesViewControllerDelegate {
    
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        
        dismiss(animated: true, completion: nil)
        
//        // some thing wrong with the cancel button
//        dismiss(animated: true) {  [weak self]  in
//            let alert = UIAlertController(title: "Wallet",
//                                          message: "成功添加到Wallet",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
//            self?.present(alert, animated: true, completion: nil)
//        }
    }
}
