//
//  ShareViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/12.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit


protocol ShareViewControllerDelegate: class {
    func closeShareView()
}

class ShareViewController: UIViewController {
    
    weak var delegate: ShareViewControllerDelegate?
    
    @IBOutlet weak var cancelButton: UIButton!
    
    // May replace brightCollectionView with page view someday
    @IBOutlet weak var brightCollectionView: UICollectionView!
    @IBOutlet weak var grayCollectionView: UICollectionView!
    
    fileprivate let brightImgs = [#imageLiteral(resourceName: "invite-sina"),
                                  #imageLiteral(resourceName: "invite-qq"),
                                  #imageLiteral(resourceName: "invite-qqspace"),
                                  #imageLiteral(resourceName: "invite-wechat"),
                                  #imageLiteral(resourceName: "invite-wechats"),
                                  #imageLiteral(resourceName: "invite-wechatw")]
    
    fileprivate let brightTitle = ["微博",
                                   "QQ好友",
                                   "QQ空间",
                                   "微信好友",
                                   "微信朋友圈",
                                   "微信收藏"];
    
    fileprivate let brightCellColor: [UIColor] = [.sinaBGColor,
                                                  .qqBGColor,
                                                  .qqZoneBGColor,
                                                  .wechatBGColor,
                                                  .wechatFriendBGColor,
                                                  .wechatStoreBGColor]
    
    fileprivate let grayImgs = [#imageLiteral(resourceName: "invite-copy"),
                                #imageLiteral(resourceName: "invite-safari"),
                                #imageLiteral(resourceName: "invite-feed"),
                                #imageLiteral(resourceName: "invite-time")];
    
    fileprivate let grayTitle = ["复制链接",
                                 "Safari 打开",
                                 "举报",
                                 "添加日历"]

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureShareView()
    }
    
    private func configureShareView() {
        
        brightCollectionView.dataSource = self
        brightCollectionView.delegate = self
        grayCollectionView.dataSource = self
        grayCollectionView.delegate = self
        
        let nib = UINib(nibName: "ShareCell", bundle: nil)
        brightCollectionView.register(nib, forCellWithReuseIdentifier: "ShareCell")
        grayCollectionView.register(nib, forCellWithReuseIdentifier: "ShareCell")
        
        let brightLayout = brightCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        brightLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let width = view.bounds.width - 20
        brightLayout.itemSize = CGSize(width: width/4.0, height: 100)
        brightLayout.minimumLineSpacing = 0
        brightLayout.minimumInteritemSpacing = 0
        
        let grayLayout = grayCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        brightLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        grayLayout.itemSize = CGSize(width: width/4.0, height: 100)
        grayLayout.minimumLineSpacing = 0
        grayLayout.minimumInteritemSpacing = 0

        brightCollectionView.collectionViewLayout = brightLayout
        grayCollectionView.collectionViewLayout = grayLayout

        cancelButton.addTarget(self, action: #selector(closeShare), for: .touchUpInside)
    }
    
    @objc private func closeShare() {
        delegate?.closeShareView()
    }

}

extension ShareViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == brightCollectionView {
            // count + 1 , 1 is more cell
            count = brightCellColor.count
        } else if collectionView == grayCollectionView {
            count = 4
        }
        return count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareCell", for: indexPath)
        if let cell = cell as? ShareCell {
            var img = UIImage()
            var title = ""
            var bgColor: UIColor = .grayBGColor
            if collectionView == brightCollectionView {
                img = brightImgs[indexPath.item]
                title = brightTitle[indexPath.item]
                bgColor = brightCellColor[indexPath.item]
            } else if collectionView == grayCollectionView {
                img = grayImgs[indexPath.item]
                title = grayTitle[indexPath.item]
            }
            
            cell.shareImageView.image = img
            cell.shareLabel.text = title
            cell.itemBackgroundView.backgroundColor = bgColor
            cell.itemBackgroundView.layer.cornerRadius = cell.itemBackgroundView.frame.width/2
        }
        return cell
    }
}

extension ShareViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == brightCollectionView {
            print("brightCollectionView")
        } else if collectionView == grayCollectionView {
            print("grayCollectionView")
        }
    }
}
