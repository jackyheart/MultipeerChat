//
//  ChatCell.swift
//  MultipeerChat
//
//  Created by Jacky on 7/7/15.
//  Copyright (c) 2015 Coolheart. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var messageTF: UILabel!
    @IBOutlet weak var dateTF: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
