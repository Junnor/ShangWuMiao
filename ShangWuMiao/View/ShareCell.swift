//
//  ShareCell.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/12.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class ShareCell: UICollectionViewCell {
    
    @IBOutlet weak var itemBackgroundView: UIView!

    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var shareImageView: UIImageView!
    
    override func layoutSubviews() {
        itemBackgroundView.layer.cornerRadius = itemBackgroundView.bounds.height / 2
        itemBackgroundView.clipsToBounds = true
    }
}
