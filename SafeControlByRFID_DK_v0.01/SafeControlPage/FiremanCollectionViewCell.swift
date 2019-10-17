//
//  FiremanCollectionView.swift
//  safe_control_by_RFID
//
//  Created by elijah tam on 2019/8/16.
//  Copyright © 2019 elijah tam. All rights reserved.
//
// 最上層顯示消防員大頭跟各種欄位的cell 暫時都不改 先吃得下DB再說

// TODO: 人多的時候 Barleft會閃一下暫時無解
import Foundation
import UIKit

class FiremanCollectionViewCell:UICollectionViewCell{
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var timestampLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var barLeftVIew: BarLeftView!
    @IBOutlet weak var enterText: UILabel!
    
    private var timestamp:TimeInterval?
    // 氣瓶時間，預設1800 單位是秒
    var barMaxTime:Double = 1800

    override func awakeFromNib() {
        // cell的圓角
        self.layer.cornerRadius = 2.0
        self.layer.borderWidth = 1.2

        // 不用變化的外觀先寫在這
        self.photo.layer.borderWidth = 1
        self.photo.layer.borderColor = UIColor.white.cgColor
        super.awakeFromNib()
        
        countDown()
    }
    
    // 準備好一個消防員的cell需要呈現的資料
    // 時間計算方法：逼逼的時候存入資料庫逼逼的時間 -> 要計算的時候用(當下時間-逼逼時間)=進去了多久
    // 因為sqlite只能存純文字 所以需要一些轉換
    // 時間戳label 應該要顯示進去多久
    func setFireman(fireman:FiremanForBravoSquad?){
        // 沒有消防員的時候顯示什麼
        if fireman == nil{
//            print("setFireman 沒有消防員")
            self.nameLable.text = nil
            self.photo.image = nil
            timestampLable.text = nil
            timestamp = nil
            // 如果格子回到空的狀態 重新設定外觀
//            changeColor(by: 1) <-- 懶人寫法 但是多做了一個空欄位的狀態所以不能用ratio=1 的預設狀態
            self.nameLable.textColor = UIColor.white
            self.enterText.textColor = UIColor.white
            self.timestampLable.textColor = UIColor.white
            self.layer.borderColor = UIColor.white.cgColor
            barLeftVIew.setBar(color: LifeCircleColor.white)
            self.backgroundColor = UIColor.clear
            
            barLeftVIew.setBar(ratio: 1)
            
            return
        }
        self.nameLable.text = fireman!.name
        self.photo.image = fireman!.image
        
        //客製化氣瓶時間
        self.barMaxTime = fireman!.scubaTime
        
        // 從資料庫讀出時間戳字串-->取最後一筆-->拿來計算(會取到逼逼出來的？)
        // 從資料庫取出並轉成陣列
        let dateStringArray = fireman!.timestamp.split(separator: ",")
        
        // 最新的一筆拿來計算？
        let latestTimeStamp = dateStringArray.last
        
        // 把他轉成可以計算的格式 String->時間戳1970格式 --> 傳給上面func外的變數給countdown用
        let doubleLtestTimeStamp = Double(latestTimeStamp!)!
        self.timestamp = doubleLtestTimeStamp
        
//        print("最後一筆時間戳\(String(describing: latestTimeStamp))")
        
        
        // 要給label顯示的時間字串格式
        let dateFormater:DateFormatter = DateFormatter()
        dateFormater.dateFormat = "HH:mm:ss"
        let dateTimeLabel = Date(timeIntervalSince1970: doubleLtestTimeStamp)
        timestampLable.text = dateFormater.string(from: dateTimeLabel)
        
        // 現在時間 - 逼楅時間
        let time_diff = Date().timeIntervalSince1970 - doubleLtestTimeStamp
        // (總氣瓶時間 -(進去了多久))/ 總時間
        
        var ratio:Double = (barMaxTime - time_diff)/barMaxTime
        ratio = ratio < 0 ? 0:ratio;
        changeColor(by: ratio)
        barLeftVIew.setBar(ratio: ratio)
    }
    
    
    //
    func countDown(){
        if timestamp == nil{
            //changeColor(by: 1)
            //barLeftVIew.setBar(ratio: 1)
//            print("func countDown 沒抓到時間戳!")
        }
        else{
            let time_diff = Date().timeIntervalSince1970 - timestamp!
            var ratio:Double = (barMaxTime - time_diff)/barMaxTime
            // 三元表達式 if ratio<0 就令 ratio=0 else ratio=ratio
            ratio = ratio < 0 ? 0:ratio;
            changeColor(by: ratio)
            barLeftVIew.setBar(ratio: ratio)
        }
        // 每0.1秒執行一次自己 直到instance解放 應該改成ratio=0就停
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.countDown()
//            print("倒數一次")
        }
    }
    
    private func changeColor(by ratio:Double){
//        print("執行設定顏色＆變換顏色")
        // 預設的格子外觀(還沒變色 或回到空欄位時) 字白色 匡綠色 背景空
        var colorSetting:LifeCircleColor = LifeCircleColor.normal
        self.nameLable.textColor = UIColor.white
        self.enterText.textColor = UIColor.white
        self.timestampLable.textColor = UIColor.white
        barLeftVIew.setBar(color: LifeCircleColor.normal)
        self.backgroundColor = UIColor.clear
        
        if ratio <= 0.5{
            colorSetting = .alert
            self.nameLable.textColor = UIColor.black
            self.enterText.textColor = UIColor.black
            self.timestampLable.textColor = UIColor.black
            barLeftVIew.setBar(color: colorSetting)
            self.backgroundColor = colorSetting.getUIColor()
        }
        if ratio < 0.3{
            colorSetting = .critical
            self.nameLable.textColor = UIColor.white
            self.enterText.textColor = UIColor.white
            self.timestampLable.textColor = UIColor.white
            barLeftVIew.setBar(color: colorSetting)
            self.backgroundColor = colorSetting.getUIColor()
        }
        
        // 因為要吃if之後的collersetting跟隨變色所以寫在後面
        self.layer.borderColor = colorSetting.getUIColor().cgColor
        
    }
}


