//
//  LogHeader.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/10/5.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import UIKit

class LogHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier: String = String(describing: self)
    @IBOutlet weak var headerDay: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    
    
    
    
    // 給註冊用的 其實註冊在init()也可以
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
