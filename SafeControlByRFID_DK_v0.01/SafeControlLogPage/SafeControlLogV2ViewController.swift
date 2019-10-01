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
        print("收到了")
    }
    
    func bleStatus(status: String) {}
}


class SafeControlLogV2ViewController: UIViewController {
    
    @IBOutlet weak var safeControlLogTable: UITableView!
    
    private var model:SafeControlModel?
    // 邪門的delegate用法在這
    func setupModel(model:SafeControlModel){
        self.model = model
        model.delegateForLog = self
    }
    
    //建立整張表格的清單陣列 名字取的根DB裡面一樣
    var firemanListforLog:Array<FiremanForLogv2>=[]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        safeControlLogTable.delegate = self
        safeControlLogTable.dataSource = self
        
        // 執行一次搜尋資料庫跟排序人員 來存到本地變數
        self.model?.firemanDB.getFiremanForLogv2()
        firemanListforLog = (self.model?.firemanDB.firemanListforLog)!
        print("存到這個view陣列中的進出紀錄清單\(firemanListforLog)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
extension SafeControlLogV2ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firemanListforLog.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell:UITableViewCell
        
        if let ttt = self.firemanListforLog[indexPath.row].timestamp{
            let icell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogInTableViewCell") as! SafeControlLogInTableViewCell
            icell.name.text = firemanListforLog[indexPath.row].name
            icell.timeStamp.text = firemanListforLog[indexPath.row].timestamp
            return icell
        }else{
            let ocell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogOutTableViewCell") as! SafeControlLogOutTableViewCell
            ocell.timeStamp.text = firemanListforLog[indexPath.row].timestampout
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
