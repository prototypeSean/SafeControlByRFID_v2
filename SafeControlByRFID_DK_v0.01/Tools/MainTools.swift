//
//  MainTools.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/9/24.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import Foundation


/// 工具: 時間戳轉成純文字
///
/// - Parameters:
///   - timestamp: 時間戳
///   - theDateFormat: "YY-MM-dd" 之類的格式
/// - Returns: "YY-MM-dd"之類的字串
public func timeStampToString(timestamp:Double, theDateFormat:String) -> String{
    let dateformate = DateFormatter()
    //Double轉成日期
    let date = Date(timeIntervalSince1970: timestamp)
    //由參數設定指定格式
    dateformate.dateFormat = theDateFormat
    return dateformate.string(from: date)
}

// 傳入的string 一定要跟 stringsDateFormat設定的格式一樣
public func timeStampStringToDate(from string:String, stringsDateFormat:String) -> Date{
    let dateformate = DateFormatter()
    dateformate.dateFormat = stringsDateFormat
    return dateformate.date(from: string)!
}

// 陣列相關： 讓index out of range可以用if let 解決
extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
