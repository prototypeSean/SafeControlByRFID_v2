//
//  SafeControlLogInTableViewCell.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/10/1.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import UIKit

class SafeControlLogInTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFiremanforCellIn(fireman:FiremanForLogv2){
        self.name.text = fireman.name
        self.timeStamp.text = timeStampToString(timestamp: fireman.timestampAbs, theDateFormat: "HH:mm:ss")
        self.avatar.image = fireman.image
    }

}
