//
//  NewExhibitionViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/26.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Kingfisher

class NewExhibitionViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var timeRemindButton: UIButton!
    private var loadedNewExhibionViewData = false
    private var newExhibition: Exhibition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNewExhibitionView()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            if !self.loadedNewExhibionViewData {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toTabBar", sender: nil)
                }
            }
        }
    }

    @IBAction func skip(_ sender: Any) {
        timer?.invalidate()
        self.performSegue(withIdentifier: "toTabBar", sender: nil)
    }

    var passDataToTabBar = false
    @IBAction func toExhibitionViewController(_ sender: Any) {
        passDataToTabBar = true
        self.performSegue(withIdentifier: "toTabBar", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toTabBar") && (passDataToTabBar == true) {
            if let tabbar = segue.destination as? TabBarViewController {
                tabbar.toNewestExhibition = true
                tabbar.newestExhibition = newExhibition
            }
        }
    }
    
    // MARK: - 本地最新一个漫展相关
    private func configureNewExhibitionView() {
        Exhibition.newLocalExhibition { (success, exhibition) in
            if success {
                self.loadedNewExhibionViewData = true
                self.newExhibition = exhibition
                self.dataWithNewExhibitionView()
            } else {
            }
        }
    }
    
    private var timer: Timer!
    private var seconds = 7
    
    private func dataWithNewExhibitionView() {
        
        if let url = URL(string: kImageHeaderUrl + newExhibition.logo!) {
            let resourcce = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            bgImageView.kf.setImage(with: resourcce,
                                                      placeholder: nil,
                                                      options: [.transition(.fade(1))],
                                                      progressBlock: nil,
                                                      completionHandler: nil)
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateUI),
                                     userInfo: nil,
                                     repeats: true)
        timer?.fire()
    }
    
    @objc private func updateUI() {
        timeRemindButton.setTitle("跳过 \(seconds) s", for: .normal)
        
        seconds -= 1
        if seconds == -1 {
            timer?.invalidate()
        }
    }
}
