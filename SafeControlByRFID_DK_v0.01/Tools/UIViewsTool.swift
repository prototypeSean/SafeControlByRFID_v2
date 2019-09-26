//
//  UIViewsTool.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/9/23.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import Foundation
import UIKit


// https://github.com/goktugyil/EZSwiftExtensions

//extension UIView {
//    func addBorderTop(size: CGFloat, color: UIColor) {
//        addBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
//    }
//    func addBorderBottom(size: CGFloat, color: UIColor) {
//        addBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
//    }
//    func addBorderLeft(size: CGFloat, color: UIColor) {
//        addBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
//    }
//    func addBorderRight(size: CGFloat, color: UIColor) {
//        addBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color)
//    }
//    private func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
//        let border = CALayer()
//        border.backgroundColor = color.cgColor
//        border.frame = CGRect(x: x, y: y, width: width, height: height)
//        layer.addSublayer(border)
//    }
//}


extension UIView {
    
    /// Adds bottom border to the view with given side margins
    ///
    /// - Parameters:
    ///   - color: the border color
    ///   - margins: the left and right margin
    ///   - borderLineSize: the size of the border
    func addBottomBorder(color: UIColor = UIColor.red, margins: CGFloat = 0, borderLineSize: CGFloat = 1) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.addConstraint(NSLayoutConstraint(item: border,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .height,
                                                multiplier: 1, constant: borderLineSize))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1, constant: margins))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1, constant: margins))
    }
}
