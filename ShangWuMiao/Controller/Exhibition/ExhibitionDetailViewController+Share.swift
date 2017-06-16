//
//  ExhibitionDetailViewController+Share.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/13.
//  Copyright © 2017年 moelove. All rights reserved.
//

import Foundation
import SVProgressHUD
import EventKit

// MARK: - Share view controller delegate

extension ExhibitionDetailViewController: ShareViewControllerDelegate {
    
    // MARK: - Public to ExhibitionDetailViewController
    
    @objc func showShareView() {
        self.shareShadowView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.shareShadowView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.shareView.frame.origin.y = self.view.frame.height - self.shareViewHeight
            
        }, completion: nil)
        
    }
    
    @objc func dismissShareView() {
        self.shareShadowView.isHidden = true
        UIView.animate(withDuration: 0.2) {
            self.shareShadowView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.shareView.frame.origin.y = self.view.frame.height
        }, completion: nil)
        
    }
    
    // MARK: - Helper
    
    private var shareUrlString: String {
        return "https://www.nyato.com/manzhan/\(exhibition.exid!)/"
    }
    
    // 添加到日历
    private func calendarAction() {
        let eventStore = EKEventStore()
        
        func insertEvent(_ store: EKEventStore) {
            let event = EKEvent(eventStore: store)
            event.calendar = store.defaultCalendarForNewEvents
            
            event.title = exhibition.name!
            event.startDate = Date(timeIntervalSince1970: TimeInterval(exhibition.start_time)!)
            event.endDate = Date(timeIntervalSince1970: TimeInterval(exhibition.end_time)!)
            event.notes = "\(exhibition.description)\n\(exhibition.location)\(exhibition.addr)"
            
            let alarm = EKAlarm()
            alarm.relativeOffset = -3600 * 24
            event.addAlarm(alarm)
            
            do {
                try store.save(event, span: .thisEvent)
                DispatchQueue.main.async {
                    SVProgressHUD.showSuccess(withStatus: "已添加事件到日历")
                }
            } catch {
                print("insert event to calendar error: \(error)")
            }
        }
        
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
        case .authorized:
            insertEvent(eventStore)
        case .denied:
            let info = "要想添加漫展事件到日历，请到设置中找到" + " 喵特商户 " + "打开日历权限"
            SVProgressHUD.showInfo(withStatus: info)
        case .notDetermined:
            eventStore.requestAccess(to: EKEntityType.event, completion: { (access, error) in
                if access {
                    insertEvent(eventStore)
                } else {
                    print("Access calendar action denied !")
                }
            })
        default: break
        }
    }
    
    // 复制链接到剪切板
    private func pasteboardAction() {
        if let url = URL(string: shareUrlString) {
            let pasteBoard = UIPasteboard.general
            pasteBoard.url = url
            SVProgressHUD.showSuccess(withStatus: "已复制链接到剪切板")
        }
    }
    
    // 问题反馈
    private func feedbackAction() {
        let identifier = "FeedbackViewController"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let feedbackVC = storyboard.instantiateViewController(withIdentifier: identifier) as! FeedbackViewController
        self.navigationController?.pushViewController(feedbackVC, animated: true)
    }
    
    // Safari 打开链接
    private func openWithSafari() {
        if let url = URL(string: shareUrlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    @objc private func share(with type: SSDKPlatformType) {
        // TODO: - replace
        if let shareUrl = URL(string: shareUrlString) {
            let title = exhibition.name!
            
            let startTime = exhibition.exhibition(stringTime: self.exhibition.start_time,
                                                  digit: false)
            let description = exhibition.location + exhibition.addr + startTime + "举办"
            
            var logoImg = UIImage()
            if let cover = exhibition.cover,
                let logoUrl = URL(string: kImageHeaderUrl + cover) {
                if let data = try? Data(contentsOf: logoUrl) {
                    logoImg = UIImage(data: data)!
                }
            }
            
            let content = title + " " + description
            
            let sharePars = NSMutableDictionary()
            var text = content
            if type == .typeSinaWeibo {
                text = "\(content) http://www.nyato.com"
            }
            
            sharePars.ssdkSetupShareParams(byText: text,
                                           images: logoImg,
                                           url: shareUrl,
                                           title: title,
                                           type: .auto)
            
            ShareSDK.share(type,
                           parameters: sharePars,
                           onStateChanged: { [weak self] (state, _, _, error) in
                            
                            self?.dismissShareView()
                            
                            switch state {
                            case .success:
                                SVProgressHUD.showSuccess(withStatus: "分享成功")
                            case .fail:
                                print("share error: \(String(describing: error))")
                                SVProgressHUD.showError(withStatus: "分享失败")
                            case .cancel:
                                print("=======share cancel")
                            default: break
                            }
            })
        }
    }
    
    
    // MARK: - Share view controller delegate
    
    func closeShareView() {
        dismissShareView()
    }
    
    func shareViewController(_ shareViewController: ShareViewController, didSelected platformType: SSDKPlatformType) {
        share(with: platformType)
    }
    
    func shareViewController(_ shareViewController: ShareViewController, didSelected grayType: GrayType) {
        dismissShareView()
        switch grayType {
        case .calendar:
            calendarAction()
        case .copy:
            pasteboardAction()
        case .report:
            feedbackAction()
        case .safari:
            openWithSafari()
        }
    }
        
    func shareViewController(_ shareViewController: ShareViewController, showMore more: Bool) {
        dismissShareView()
        // apple original UIActivityViewController
        if let url = URL(string: shareUrlString), let title = exhibition.name {
            let activity = UIActivityViewController(activityItems: [title, url],
                                                    applicationActivities: nil)
            activity.modalPresentationStyle = .popover
            activity.popoverPresentationController?.sourceView = self.shareView
            present(activity, animated: true, completion: nil)
        }
    }
}
