//
//  BarLeftView.swift
//  safe_control_by_RFID
//
//  Created by elijah tam on 2019/8/16.
//  Copyright © 2019 elijah tam. All rights reserved.
//

import Foundation
import UIKit

enum LifeCircleColor{
    case normal
    case alert
    case critical
    case white
    
    public func getUIColor() -> UIColor{
        switch self {
        case .normal:
            return #colorLiteral(red: 0.3450980392, green: 0.968627451, blue: 0.8549019608, alpha: 1)
        case .alert:
            return #colorLiteral(red: 1, green: 0.8352941176, blue: 0, alpha: 1)
        case .critical:
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case .white:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}

class BarLeftView:UIView{
    var barRatio:Double = 1
    var barColor:LifeCircleColor = .white
    private let barLayer = CAShapeLayer()
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.backgroundColor = UIColor.clear
        self.layer.addSublayer(barLayer)
        
        // 原本是 self.bounds.width
        barLayer.lineWidth = 9
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let bezi = UIBezierPath()
        // 想要讓線條至中的話 x: self.bounds.width/2
        bezi.move(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        bezi.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height*CGFloat(1 - barRatio)))
        barLayer.path = bezi.cgPath
        barLayer.strokeColor = barColor.getUIColor().cgColor
    }
    
    
    /// 設定bar長度
    func setBar(ratio:Double){
        // 修正 ratio 範圍 防止超過 0~1
        self.barRatio = ratio > 0 ? (ratio < 1 ? ratio:1):0
        //self.layoutIfNeeded()
        self.setNeedsDisplay()
        
    }
    /// 設定bar的顏色
    func setBar(color:LifeCircleColor){
        self.barColor = color
        //self.setNeedsDisplay()
    }
}
