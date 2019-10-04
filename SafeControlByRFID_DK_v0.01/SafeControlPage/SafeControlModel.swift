//
//  SafeControllModel.swift
//  safe_control_by_RFID
//
//  Created by elijah tam on 2019/8/15.
//  Copyright © 2019 elijah tam. All rights reserved.
//
// 人員管制頁面的資料處理
//
import Foundation
import UIKit
// 只是個時間點的flag的樣子
protocol SafeControlModelDelegate{
    func dataDidUpdate()
    func bleStatus(status:String)
}

protocol SafeControldelegateforAddNewFireman{
    func newFiremanRFID(uuid:String)
}
// 顯示用的小隊：陣列<消防員>
struct BravoSquad {
    var fireMans:Array<FiremanForBravoSquad>
}


class SafeControlModel:NSObject{
    
    
    // 連上資料庫（這邊要用let還是var尚存疑）
    let firemanDB = FirecommandDatabase()
    
    // 所有的小隊-- 每個小隊一個tableViewCell 每個Cell一個BravoSquad
    private var bravoSquads:Array<BravoSquad> = []
    // 進出紀錄log
    private(set) var logEnter:Array<FiremanForBravoSquad> = []
    private(set) var logLeave:Array<FiremanForBravoSquad> = []
    
    
    
    
    // 初始化的時候把藍芽連上 把要顯示的各小隊跟隊員準備好
    override init() {
        super.init()
        BluetoothModel.singletion.delegate = self
        bravoSquads.append(BravoSquad(fireMans: []))
    }
    
    // 資料更新的時候用的旗子
    var delegate:SafeControlModelDelegate?
    var delegateForLog:SafeControlModelDelegate?
    var delegateForLogV2:SafeControlModelDelegate?
    var delegateForAddFireman:SafeControldelegateforAddNewFireman?
    
    // 吃uuid當參數 試著把人從小隊中移出 並寫入logLeave中，移出成功＝true
    private func removeFireman(by uuid:String) -> Bool{
        for bravoSquadIndex in 0 ..< bravoSquads.count{
            // 從bravoSquads的陣列中遍歷，找uuid符合的fireman
            if let index = bravoSquads[bravoSquadIndex].fireMans.firstIndex(where: {$0.uuid == uuid}){
                // 找到之後把他加離開的log陣列中 並且從bravoSquad中移出
//                logLeave.append(bravoSquads[bravoSquadIndex].fireMans[index])
                bravoSquads[bravoSquadIndex].fireMans.remove(at: index)
                // 更新資料庫移出ＬＯＧ
                firemanDB.updateFiremanForBravoSquadaTimeOut(by: uuid)
                print("移出消防員")
                return true
            }
        }
        
        
        print("沒有此消防員可以移出")
        return false
    }
    
    // 與移出成對，把消防員加入BravoSquad，加入成功＝true
    private func addFireman(by uuid:String) -> Bool{
        print("嘗試加入消防員到小隊中")
        // 這個 getFiremanforBravoSquad 包含了畢畢時間存入DB
        // 嗶嗶的時候要更新log以外 要存入資料庫
        // log 頁面要顯示歷史紀錄
        
        
        
        if let fireman = firemanDB.getFiremanforBravoSquad(by: uuid){
//            print("嘗試加入消防員到小隊中\(fireman)")
//            logEnter.append(fireman)
            bravoSquads[0].fireMans.append(fireman)
//            firemanDB.updateFiremanForBravoSquadaTime(by: uuid)
            return true
        }
        return false
    }
    
//    func getFiremanEnterLog() -> Array<FiremanForBravoSquad>{
//        var enterLog:Array<FiremanForBravoSquad>?
//
//        return enterLog!
//    }
    
    
    private func sortLogData(){
        logEnter.sort(by: {$0.uuid > $1.uuid})
        logEnter.sort { (a, b) -> Bool in
            return a.uuid > b.uuid
        }
        logLeave.sort(by: {$0.uuid > $1.uuid})
    }
}

// public API
extension SafeControlModel{
    func getBravoSquads() -> Array<BravoSquad>{
        return self.bravoSquads
    }
    
    // 不確定什麼時候該把資料庫中的log傳到 array 裡面, 不能在init因為第一次開app時資料庫還不存在
    func syncBravoSquadLog(){
        firemanDB.allfiremanForLogPage()
        firemanDB.makefiremanLogPageV2()
//        logEnter = firemanDB.arrayEnter
//        logLeave = firemanDB.arrayExit
    }
    
}

// delegate from bluetooth 收到藍牙傳來的UUID 就新增或移除人員,然後再給兩個ＶＣ一根旗子讓他們刷新頁面
extension SafeControlModel:BluetoothModelDelegate{
    func didReciveRFIDDate(uuid: String) {
        print("收到RFID:--處理中")
        
        // 檢查是不是在不該觸發嗶嗶人員的view（要import UIKit）
        if let wd = UIApplication.shared.delegate?.window {
            var vc = wd!.rootViewController
            if(vc is UINavigationController){
                vc = (vc as! UINavigationController).visibleViewController
                
            }
            
            if(vc is SafeControlViewController || vc is SafeControlLogPageViewController || vc is SafeControlLogV2ViewController){
                // 觸發消防員進入或離開火場功能 嗶嗶就先移除，失敗再新增
                // 如果移除成功就會遇到return跳出迴圈
                if !removeFireman(by: uuid){
                    if(!addFireman(by: uuid)){
                        print("uuid not fuund in database!")
                    }
                }
            }
        }
        //畢畢的時候也要同步一次（會不會資料量太大？）
        syncBravoSquadLog()
        sortLogData()
        delegate?.dataDidUpdate()
        delegateForLog?.dataDidUpdate()
        delegateForLogV2?.dataDidUpdate()
        delegateForAddFireman?.newFiremanRFID(uuid: uuid)
    }
    func bluetoothStatusUpdate(status:String){
        delegate?.bleStatus(status: status)
    }

}
