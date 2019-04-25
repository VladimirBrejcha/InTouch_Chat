//
//  CustomMessageCell.swift
//  InTouch chat
//
//  Created by Vladimir Brejcha on 25/04/2019.
//  Copyright @2019 Vladimir Korolev. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {


    @IBOutlet var messageBackground: UIView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var senderUsername: UILabel!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSpecialConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSpecialConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code goes here
        
    }


}
