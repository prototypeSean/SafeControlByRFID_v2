//
//  SafeControlViewController.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/8/30.
//  Copyright © 2019 DennisKao. All rights reserved.
//
// 人員管制的首頁
// 安管頁面最外層的VC 要吃下兩個協議來使用tableView的func

import UIKit


// 第一次收到收到RFID要把人放到清單上 第二次要移除(先試著移除失敗就加入)
// 這裡的資料靠 SafeControlModel 提供
class SafeControlViewController: UIViewController{
    
    var divideBy:Float = 4.0
    //     監聽裝置旋轉
    @objc func didOrientationChange(_ notification: Notification) {
        print("other")
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            self.divideBy = 5.0
            print("landscape")
        case .portrait, .portraitUpsideDown:
            self.divideBy = 4.0
            print("portrait")
        default:
            print("other")
        }
    }
    
    var firecommandDB: FirecommandDatabase!

    let model = SafeControlModel()
    
    @IBOutlet weak var SafeControlTableView: UITableView!
    
    @IBOutlet weak var bluetoothStatus: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        SafeControlTableView.delegate = self
        SafeControlTableView.dataSource = self
        self.model.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 建立DB連線
        firecommandDB = FirecommandDatabase()
        firecommandDB.createTableFireman()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToLogPage"{
            self.model.syncBravoSquadLog()
            let destinationtolog = segue.destination as! SafeControlLogPageViewController
            destinationtolog.setupModel(model: model)
        }
        
        if segue.identifier == "segueToAddNewFireman"{
            let destinationtoAdd = segue.destination as! AddNewFiremanViewController
            /// 有點邪門的寫法，因為註冊頁面是child的關係，這樣兩個VC都會收到delegate
            destinationtoAdd.setupModel(model: model)
        }
//        self.model.delegate = nil
        
        
    }
}

extension SafeControlViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.getBravoSquads().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BravoSquadTableViewCell") as! BravoSquadTableViewCell
        let bravoSquad = model.getBravoSquads()[indexPath.row]
        cell.setBravoSquad(bravoSquad: bravoSquad)
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let cell = tableView.cellForRow(at: indexPath) as? BravoSquadTableViewCell{
//        let bravoSquad = model.getBravoSquads()[indexPath.row]
//        print("condition:\(cell.ppp.count)")
        
        // 根據現在平版狀態直向橫向來給出可能要變更的行高
        NotificationCenter.default.addObserver(self, selector: #selector(self.didOrientationChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // 計算現在小隊中有多少人用來計算顯示需要的行數(計算用的數字都是float才能無條件進位)
        let firemansInbravoSquad = Float(model.getBravoSquads()[indexPath.row].fireMans.count)
        var rows = ceil(firemansInbravoSquad / divideBy)
        if rows < 3{
            rows = 3
        }
        return CGFloat(rows*420)
//        if cell.ppp.count >= 5 && indexPath.section == 0{
//
//            print("ppp高度高度\(CGFloat(cell.ppp.count*600))")
//            return CGFloat(cell.ppp.count/5*600)
//        }else
//        {
//            return 600
//            }}
//        return 600
    }
}

extension SafeControlViewController:SafeControlModelDelegate{
    func dataDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.SafeControlTableView.reloadData()
            print("更新資料by Model delegate & 已執行 -- reloadData")
        
        }
    }
}
