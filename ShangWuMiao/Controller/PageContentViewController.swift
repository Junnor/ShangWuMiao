//
//  PageContentViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/26.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var pageIndex: Int!
    
    var imageName: String?
    var pageTitle: String?
    
    var bgColor: UIColor?
    var labelFrame: CGRect!
    
    var promptImageName: String?
    
    // MARK: - View Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isLastPage = (pageIndex == 3)
        
        setBgImageView()
        setPromptImageView()
        
        if isLastPage {
            setActionButton()
        }
//        setPageTitle()
        
        view.backgroundColor = bgColor
    }
    
    // MARK: - For Button
    private var isLastPage = false
    private var actionButton: UIButton!
    
    private func setActionButton() {
        
        var frame = self.view.convert(self.textImageView.frame, to: nil)
        frame.origin.y -= 70
        frame.size.height = 40
        
        actionButton = UIButton(frame: frame)
        actionButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        actionButton.setTitle("Login", for: .normal)
        
        view.addSubview(actionButton)
    }
    
    @objc private func login() {
        NotificationCenter.default.post(name: toLoginViewController, object: nil)
    }
    
    // MARK: - Helper
    
    private func setBgImageView() {
        let xEdge: CGFloat = 30.0
        let yEdge: CGFloat = 100.0
        
        var frame = UIScreen.main.bounds
        frame.size.width = frame.size.width - 2 * xEdge
        frame.size.height = frame.width
        frame.origin.x = xEdge
        frame.origin.y = yEdge
        
        let imageView = UIImageView(frame: frame)
        view.addSubview(imageView)
        if imageName != nil {
            imageView.image = UIImage(named: imageName!)
        }
    }
    
    
    private var textImageView: UIImageView!
    private func setPromptImageView() {
        let xEdge: CGFloat = 30.0
        let bottonSpace: CGFloat = 100.0
        
        // 720 / 96 = scale of image.width / image.height
        var frame = UIScreen.main.bounds
        frame.size.width = frame.size.width - 2 * xEdge
        frame.size.height = frame.width * (96.0 / 720)
        frame.origin.x = xEdge
        frame.origin.y =  UIScreen.main.bounds.height - bottonSpace
        
        let imageView = UIImageView(frame: frame)
        view.addSubview(imageView)
        if imageName != nil {
            imageView.image = UIImage(named: promptImageName!)
        }
        
        if isLastPage {
            textImageView = imageView
        }
    }
    
    private func setPageTitle() {
        let titleLabel = UILabel(frame: labelFrame)
        titleLabel.text = pageTitle
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
    }
    
}
