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
    
    func shareViewController(_ shareViewController: ShareViewController, didSelected platformType: SSDKPlatformType)
    
    func shareViewController(_ shareViewController: ShareViewController, didSelected grayType: GrayType)
    
    func shareViewController(_ shareViewController: ShareViewController, showMore more: Bool)
}

enum GrayType: Int {
    case copy = 0
    case safari
    case report
    case calendar
}


class ShareViewController: UIViewController {
    
    // MARK: - Public properties

    weak var delegate: ShareViewControllerDelegate?
    
    // MARK: Outlets
    
    @IBOutlet weak var cancelButton: UIButton!
    
    // May replace brightCollectionView with page view someday
    @IBOutlet weak var brightCollectionView: UICollectionView!
    @IBOutlet weak var grayCollectionView: UICollectionView!
    
    // MARK: - Private properties
    
    fileprivate let brightImgs = [#imageLiteral(resourceName: "invite-sina"),
                                  #imageLiteral(resourceName: "invite-qq"),
                                  #imageLiteral(resourceName: "invite-qqspace"),
                                  #imageLiteral(resourceName: "invite-wechat"),
                                  #imageLiteral(resourceName: "invite-wechats"),
                                  #imageLiteral(resourceName: "invite-wechatw"),
                                  #imageLiteral(resourceName: "ico-more")]
    
    fileprivate enum ShareBright: Int {
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
                plat = .subTypeQZone
            case .qqFriend:
                plat = .typeQQ
            case .wechatFriend:
                plat = .subTypeWechatSession
            case .wechatZone:
                plat = .subTypeWechatTimeline
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
                                   "微信收藏",
                                   "更多"];
    
    fileprivate let brightCellColor: [UIColor] = [.sinaBGColor,
                                                  .qqBGColor,
                                                  .qqZoneBGColor,
                                                  .wechatBGColor,
                                                  .wechatFriendBGColor,
                                                  .wechatStoreBGColor,
                                                  UIColor.white]
    
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
        
        // Only perform once
        configureShareView()        
    }
    
    fileprivate var sectionInsets: UIEdgeInsets!
    fileprivate let itemWidth: CGFloat = 70
    fileprivate let itemHeight: CGFloat = 100
    fileprivate var lineSpace: CGFloat = 5
    fileprivate let rowCount = 4
    fileprivate let cellPading: CGFloat = 16
    
    fileprivate func configureShareView() {
        brightCollectionView.dataSource = self
        brightCollectionView.delegate = self
        grayCollectionView.dataSource = self
        grayCollectionView.delegate = self
        
        let nib = UINib(nibName: "ShareCell", bundle: nil)
        brightCollectionView.register(nib, forCellWithReuseIdentifier: "ShareCell")
        grayCollectionView.register(nib, forCellWithReuseIdentifier: "ShareCell")
        
        cancelButton.addTarget(self, action: #selector(closeShare), for: .touchUpInside)
        
        let padding = (view.bounds.width - CGFloat(rowCount) * itemWidth + cellPading * 2) / 5
        lineSpace = padding - cellPading
        sectionInsets = UIEdgeInsets(top: 10, left: padding, bottom: 0, right: padding)
    }
    
    @objc private func closeShare() {
        delegate?.closeShareView()
    }

}

// MARK: - Collection view datasource

extension ShareViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == brightCollectionView {
            count = brightTitle.count
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
                
                // set for more item cell
                if indexPath.item == brightCellColor.count - 1 {
                    cell.itemBackgroundView.layer.borderColor = UIColor.gray.cgColor
                    cell.itemBackgroundView.layer.borderWidth = 1.0
                    cell.shareImageView.contentMode = .center
                }
                
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

// MARK: - Collection view delegate

extension ShareViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == brightCollectionView {
            if indexPath.row == brightTitle.count - 1 {  // more item
                delegate?.shareViewController(self, showMore: true)
            } else {   // normal item
                if let type = ShareBright(rawValue: indexPath.row) {
                    delegate?.shareViewController(self, didSelected: type.value)
                }
            }
        } else if collectionView == grayCollectionView {
            if let type = GrayType(rawValue: indexPath.row) {
                delegate?.shareViewController(self, didSelected: type)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpace
    }
}
