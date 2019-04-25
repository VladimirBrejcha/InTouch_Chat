//
//  CustomMessageCell.swift
//  InTouch chat
//
//  Created by Vladimir Brejcha on 25/04/2019.
//  Copyright @2019 Vladimir Korolev. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {

    @IBOutlet var messageBody: UILabel!
    @IBOutlet var senderUsername: UILabel!
    
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!

    @IBOutlet weak var backgroundViewWidth: NSLayoutConstraint!
}
