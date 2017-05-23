//
//  CornerView.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/23.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit


@IBDesignable
class CornerTextField: UITextField {
    
    @IBInspectable
    var cornerRadius: CGFloat = 23 { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
}

@IBDesignable
class CornerButton: UIButton {

    @IBInspectable
    var cornerRadius: CGFloat = 23 { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }

}
