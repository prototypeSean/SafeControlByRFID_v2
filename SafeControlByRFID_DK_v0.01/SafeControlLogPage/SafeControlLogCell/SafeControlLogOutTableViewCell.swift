//
//  SafeControlLogOutTableViewCell.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/10/1.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import UIKit

class SafeControlLogOutTableViewCell: UITableViewCell {
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatar.layer.cornerRadius = (self.avatar.layer.bounds.height)/2
        self.avatar.layer.borderWidth = 1   
        self.avatar.layer.borderColor = #colorLiteral(red: 0.3450980392, green: 0.968627451, blue: 0.8549019608, alpha: 1)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setFiremanforCellOut(fireman:FiremanForLogv2){
        self.name.text = fireman.name
        self.timeStamp.text = timeStampToString(timestamp: fireman.timestampAbs, theDateFormat: "HH:mm:ss")
        self.avatar.image = fireman.image
    }
}
