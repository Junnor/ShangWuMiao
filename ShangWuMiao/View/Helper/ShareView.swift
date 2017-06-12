//
//  ShareView.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/12.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class ShareView: UIView {

    @IBOutlet weak var cancelButton: UIButton!
    
    // May replace brightCollectionView with page view someday
    @IBOutlet weak var brightCollectionView: UICollectionView!
    @IBOutlet weak var grayCollectionView: UICollectionView!
}


extension UIView {
    
    static func loadViewFromXib(_ xid: String) -> UIView {
       return Bundle.main.loadNibNamed("xid",
                                 owner: nil,
                                 options: nil)?.first as! UIView
    }
}
