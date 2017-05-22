//
//  TicketOrderCell.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/10.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit

class AccessoryButton: UIButton {
    var indexPath: IndexPath!
}

// 门票订单
class TicketOrderCell: UITableViewCell {
    @IBOutlet weak var orderImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var sendMessageButton: AccessoryButton!
}
