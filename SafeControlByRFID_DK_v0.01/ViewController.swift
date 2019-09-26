//
//  ViewController.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/8/28.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import UIKit

class SafeControllController: UIViewController, BluetoothModelDelegate{
    func didReciveRFIDDate(uuid: String) {
        print("didReciveRFIDDate ＝ \(uuid)")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        BluetoothModel.singletion.delegate = self
    }


}

