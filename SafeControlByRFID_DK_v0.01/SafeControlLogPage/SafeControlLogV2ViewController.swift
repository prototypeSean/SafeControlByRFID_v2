//
//  SafeControlLogV2ViewController.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/10/1.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import UIKit

extension SafeControlLogV2ViewController: SafeControlModelDelegate{
    func dataDidUpdate() {
        
        DispatchQueue.main.async {
            self.logPageArray.removeAll()
            // 這邊也要取得 DB 來的資料
            self.model?.firemanDB.makefiremanLogPageV2()
            self.logPageArray = (self.model?.firemanDB.firemanLogPageV2)!
            self.safeControlLogTable.reloadData()
            
            print("22222222222\(self.logPageArray)")
        }
    }
    
    func bleStatus(status: String) {}
}


class SafeControlLogV2ViewController: UIViewController {
    
    @IBOutlet weak var safeControlLogTable: UITableView!
    
    private var model:SafeControlModel?
    
    // 此 tableView 的總陣列
    var logPageArray:Array<logPageV2>=[]
    
    
    // 邪門的delegate用法在這
    func setupModel(model:SafeControlModel){
        self.model = model
        model.delegateForLog = self
    }
    
    //建立整張表格的清單陣列 名字取的跟DB裡面一樣
//    var firemanListforLog:Array<FiremanForLogv2>=[]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.safeControlLogTable.allowsSelection = false
        safeControlLogTable.delegate = self
        safeControlLogTable.dataSource = self
        
        // 執行一次搜尋資料庫跟排序人員 來存到本地變數
//        self.model?.firemanDB.getFiremanForLogv2()
        
        // 取得 DB 來的資料
        self.model?.firemanDB.makefiremanLogPageV2()
        self.logPageArray = (self.model?.firemanDB.firemanLogPageV2)!
        
//        firemanListforLog = (self.model?.firemanDB.firemanListforLog)!
        print("存到這個view陣列中的進出紀錄清單\(logPageArray)")
        
        self.safeControlLogTable.register(LogHeader.nib, forHeaderFooterViewReuseIdentifier: "LogHeader")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension SafeControlLogV2ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.logPageArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logPageArray[section].oneDayFiremanLog.count
    }
    
    // 設定清單標題（依日期區分）
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "LogHeader")
            as? LogHeader
        headerView?.headerDay.text = logPageArray[section].deployDay
        headerView?.headerTitle.text = "進出時間"
        
        return headerView
        
//        let headerView = UIView()
//        headerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1001712329)
//
//        let headerDayLabel = UILabel(frame: CGRect(x: 30, y: 5, width:
//            tableView.bounds.size.width, height: tableView.bounds.size.height))
//
//        let headerCenterLabel = UILabel(frame: CGRect(x: tableView.bounds.size.width/2, y: 5, width: 60, height: tableView.bounds.size.height))
//        headerCenterLabel.text = "進出時間"
//
//        headerDayLabel.textColor = UIColor.white
//        //        headerLabel.addBorderBottom(size: 2.0, color: UIColor.white)
//        if tableView.restorationIdentifier == "enter"{
//            headerDayLabel.text = logPageArray[section].deployDay
//        }else{
//            headerDayLabel.text = logPageArray[section].deployDay
//        }
//        headerDayLabel.sizeToFit()
//        headerView.addSubview(headerDayLabel)
//        headerView.addSubview(headerCenterLabel)
//        return headerView

    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30   
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell:UITableViewCell
        // 利用 indexPath 會遍歷的特性來跑整個消防員清單 如果timestamp不是nil 就表示是"進入cell"
        let eachFmLog = self.logPageArray[indexPath.section].oneDayFiremanLog[indexPath.row]
        if eachFmLog.timestamp != nil{
            let icell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogInTableViewCell") as! SafeControlLogInTableViewCell
            icell.setFiremanforCellIn(fireman: eachFmLog)
//
//            icell.name.text = eachFmLog.name
//            icell.timeStamp.text = timeStampToString(timestamp: Double(timestampIn)!, theDateFormat: "HH:mm:ss")
//            icell.avatar.image = eachFmLog.image
            return icell
        }else{
//            let timestampout = eachFmLog.timestampout!
            let ocell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogOutTableViewCell") as! SafeControlLogOutTableViewCell
            ocell.setFiremanforCellOut(fireman: eachFmLog)
//            ocell.timeStamp.text = timeStampToString(timestamp: Double(timestampout)!, theDateFormat: "HH:mm:ss")
            return ocell
        }
        
        
//        for x in indexPath{
//            print(x)
//        }
//
//        let incell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogInTableViewCell") as! SafeControlLogInTableViewCell
//        incell.name.text = firemanListforLog[indexPath.row].name
//
//        return incell
////
//
//        for m in firemanListforLog{
//            if m.timestamp != nil{
//                let incell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogInTableViewCell") as! SafeControlLogInTableViewCell
//                incell.timeStamp.text = m.timestamp
//                return incell
//            }else{
//                let outcell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogOutTableViewCell") as! SafeControlLogOutTableViewCell
//                outcell.timeStamp.text = m.timestampout
//
//                return outcell
//            }
//        }
        
//        if indexPath.row == 1{
//            cell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogInTableViewCell") as! SafeControlLogInTableViewCell
//        }else{
//            cell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogOutTableViewCell") as! SafeControlLogOutTableViewCell
//        }
//
//        return cell
    }
}
