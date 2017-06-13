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
    
    var platformType: SSDKPlatformType = .typeUnknown
    
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
    
    fileprivate enum Bright: Int {
        case sina = 0
        case qqFriend
        case qqZone
        case wechatFriend
        case wechatZone
        case wechatStore
        
        var value: SSDKPlatformType {
            var plat = SSDKPlatformType.typeUnknown
            switch self {
            case .sina:
                plat = .typeSinaWeibo
            case .qqZone:
                plat = .subTypeQQFriend
            case .qqFriend:
                plat = .subTypeQQFriend
            case .wechatFriend:
                plat = .typeWechat
            case .wechatZone:
                plat = .subTypeWechatSession
            case .wechatStore:
                plat = .subTypeWechatFav
            }
            return plat
        }
    }
    
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
    
    fileprivate enum Gray: Int {
        case copy = 0
        case safari
        case report
        case calendar
    }
    
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

extension ShareViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == brightCollectionView {
            print("brightCollectionView")
            if let type = Bright(rawValue: indexPath.row) {
                platformType = type.value
            }
        } else if collectionView == grayCollectionView {
            print("grayCollectionView")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding = (collectionView.bounds.width - 4 * 80) / 2
        return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}