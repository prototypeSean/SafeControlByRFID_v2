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
    var squadTitle:String
    var fireMans:Array<FiremanForBravoSquad>
    var rowIsSelected:Bool
    var indexInTableView:Int
    var isSettingCap:Bool
    var capName:String
    var capCallSign:String
}

class SafeControlModel:NSObject{
    
    
    // 連上資料庫（這邊要用let還是var尚存疑）
    let firemanDB = FirecommandDatabase()
    
    // 所有的小隊-- 每個小隊一個tableViewCell 每個Cell一個BravoSquad
    private var bravoSquads:Array<BravoSquad> = []
    // 進出紀錄log
    private(set) var logEnter:Array<FiremanForBravoSquad> = []
    private(set) var logLeave:Array<FiremanForBravoSquad> = []
    
    // BravoSquad 的選取狀態 （現在要從哪個squad登錄）
    var selectionStatus:(priviousRow:Int,currentRow:Int) = (0,0)
    
    func didSelect(row:Int){
        print("自己寫的didselect主要用來操作矩陣的取消選取")
//        if self.selectionStatus.priviousRow != self.selectionStatus.currentRow{
            self.selectionStatus.priviousRow = self.selectionStatus.currentRow
            self.selectionStatus.currentRow = row
        
            // 先取消選取，再選取才能避免存錯資料到array
            self.bravoSquads[selectionStatus.priviousRow].rowIsSelected=false
            self.bravoSquads[row].rowIsSelected = true
        
            print("\(self.bravoSquads)")
//        }
    }
    
    // 初始化的時候把藍芽連上 把要顯示的各小隊跟隊員準備好
    override init() {
        super.init()
        BluetoothModel.singletion.delegate = self
        bravoSquads.append(BravoSquad(squadTitle: "第一面", fireMans: [], rowIsSelected: true, indexInTableView: 0, isSettingCap: false, capName: "隊長名", capCallSign: "設定隊長"))
        bravoSquads.append(BravoSquad(squadTitle: "第二面", fireMans: [], rowIsSelected: false, indexInTableView: 1, isSettingCap: false, capName: "隊長名", capCallSign: "設定隊長"))
//        self.addNewBrevoSquad(title: "第二小隊")
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
        // 這個 getFiremanforBravoSquad 包含了畢畢時間存入DB
        // 嗶嗶的時候要更新log以外 要存入資料庫
        // log 頁面要顯示歷史紀錄
        
        // 取得目前被選取的 squad Index (也就是cell index)
        let selectedSquadIndex = getSelectedSquad().index
        if let fireman = firemanDB.getFiremanforBravoSquad(by: uuid){
//            print("嘗試加入消防員到小隊中\(fireman)")
            bravoSquads[selectedSquadIndex].fireMans.append(fireman)
//            bravoSquads[0].fireMans.append(fireman)
//            firemanDB.updateFiremanForBravoSquadaTime(by: uuid)
            return true
        }
        return false
    }
    
    
    func addNewBrevoSquad(title:String){
        bravoSquads.append(BravoSquad(squadTitle: title, fireMans: [], rowIsSelected: false, indexInTableView: bravoSquads.count, isSettingCap: false, capName: "隊長名", capCallSign: "設定隊長"))
    }
    
    func removeBravoSquad(title:String){
        if let removeIndex:Int = bravoSquads.firstIndex(where:{$0.squadTitle == title}){
            bravoSquads.remove(at: removeIndex)
        }
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
    
    // 選取要登錄的 ROW (SQUAD)
    func selectBravoSquad(by index:Int){
        self.bravoSquads[index].rowIsSelected = true
    }
    
    func deSelectBravoSquad(by index:Int){
        self.bravoSquads[index].rowIsSelected = false
    }
    
    // 選取要移動的 FIREMAN (collectionViewCell)
    func selectedFireman(in squad:Int, place:Int){
        if (self.bravoSquads[safe:squad]?.fireMans[safe:place]?.manIsSelected) != nil{
            self.bravoSquads[squad].fireMans[place].manIsSelected = true
        }
    }
    
    func deSelectedFireman(in squad:Int, place:Int){
        if (self.bravoSquads[safe:squad]?.fireMans[safe:place]?.manIsSelected) != nil{
            self.bravoSquads[squad].fireMans[place].manIsSelected = false
        }
    }
    
    //哪一行被按下「設定隊長」按鈕
    func startSettingCap(at row:Int){
        self.bravoSquads[row].isSettingCap = true
    }
    
    func endSettingCap(at row:Int){
        self.bravoSquads[row].isSettingCap = false
    }
    
    // 已選擇隊長
    // 要檢查是不是已經有隊長 有的話要置換
    func selectedCaptainToModel(in squad:Int, place:Int){
        let currentCap = self.bravoSquads[squad].fireMans.first(where: {$0.isLeader == true})
        print("目前隊長、\(currentCap?.name)")
        
        let newCap = self.bravoSquads[squad].fireMans[place]
        
        if newCap.uuid == currentCap?.uuid{
            print("同一個隊長，無需替換")
        }else{
            let deSelectedCapIndex = self.bravoSquads[squad].fireMans.firstIndex(where: {$0.uuid == currentCap?.uuid})
            self.bravoSquads[squad].fireMans[deSelectedCapIndex ?? 0].isLeader = false
            
            self.bravoSquads[squad].fireMans[place].isLeader = true
            self.bravoSquads[squad].capName = newCap.name
            self.bravoSquads[squad].capCallSign = newCap.callSign
            print("已變更隊長\(newCap.name)")
            for aaa in bravoSquads[squad].fireMans{
                print("name \(aaa.name),is cap \(aaa.isLeader)")
            }
        }
        
        
        self.bravoSquads[squad].fireMans[place].isLeader = true
    }
    //取消選擇隊長
    func deSelectedCaptainToModel(in squad:Int, place:Int){
        self.bravoSquads[squad].fireMans[place].isLeader = false
    }
    
    
    
    /// 重新編組消防員（把已經被選取的人員清單，移入被按下「移入人員」按鈕的小隊）
    ///
    /// - Parameters:
    ///   - squadRow: 要移入哪個Squad (cell所在的row index)
    ///   - selectedList: 哪些人要被移入（bravoSquads的fireman index）
    func reArrengementSquad(into squadRow:Int, selectedList:Array<(row:Int, item:Int)>){
//        print("squad==\(squadRow), array\(selectedList)")
        // 寫個變數來存比較安心 這裡面的操作都用這個陣列
        var selectedFm:Array<FiremanForBravoSquad> = []
        
        // 把選取的人整理到上面的變數裡
        for (squad,man) in selectedList{
            // 把選取的人存進變數之前 先取消選取狀態＝isSelected＝false
            var manSelectedtoFalse = self.bravoSquads[squad].fireMans[man]
            manSelectedtoFalse.manIsSelected = false
            selectedFm.append(manSelectedtoFalse)
        }
        
        for removeman in selectedFm{
            // 因為是用ＲＦＩＤ移除所以剛剛改為否那邊不會影響操作
            // 基本上照抄removeFireman()但是不要動到DB
            for bravoSquadIndex in 0 ..< bravoSquads.count{
                // 從bravoSquads的陣列中遍歷，找uuid符合的fireman
                if let index = bravoSquads[bravoSquadIndex].fireMans.firstIndex(where: {$0.uuid == removeman.uuid}){
                    // 找到之後把他加離開的log陣列中 並且從bravoSquad中移出
                    //                logLeave.append(bravoSquads[bravoSquadIndex].fireMans[index])
                    bravoSquads[bravoSquadIndex].fireMans.remove(at: index)
                    print("移出消防員")
                }
                else{
                    print("移出消防員\(removeman.name)失敗")
                }
            }
        }
        // 在要插入的小隊中加入本地存好的消防員陣列
        self.bravoSquads[squadRow].fireMans += selectedFm
    }
    
    
    
    // 找出現在哪個小隊被點選 要嗶嗶進入這小對了
    func getSelectedSquad() -> (squad:BravoSquad,index:Int){
        let bravoSquads = self.bravoSquads
        if let targetSquad = bravoSquads.firstIndex(where: {$0.rowIsSelected == true}){
            return (bravoSquads[targetSquad],targetSquad)
        }else{
            return (bravoSquads[0],0)
        }
    }
    
    func reNameBLENFCDevide(){
        BluetoothModel.singletion.reNameBLENFCDevide(as: "Dev_00")
    }
    
    // 不確定什麼時候該把資料庫中的log傳到 array 裡面, 不能在init因為第一次開app時資料庫還不存在
    func syncBravoSquadLog(){
//        firemanDB.allfiremanForLogPage()
//        firemanDB.makefiremanLogPageV2()
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
                
                syncBravoSquadLog()
                sortLogData()
                delegate?.dataDidUpdate()
                delegateForLog?.dataDidUpdate()
                delegateForLogV2?.dataDidUpdate()
                
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
        
        delegateForAddFireman?.newFiremanRFID(uuid: uuid)
    }
    func bluetoothStatusUpdate(status:String){
        delegate?.bleStatus(status: status)
    }

}
