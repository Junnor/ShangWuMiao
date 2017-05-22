//
//  ExBlurView.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/19.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class ExBlurView: UIView {

    @IBOutlet weak var blurImageView: UIImageView!
    
    static func blurViewFromNib() -> ExBlurView {
        return  Bundle.main.loadNibNamed("ExBlurView",
                                         owner: nil,
                                         options: nil)![0] as! ExBlurView
    }

}
