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
    
    // 按下新增小隊按鈕
    @IBAction func addNewSquadBtn(_ sender: UIButton) {
        
        let controller = UIAlertController(title: "新增小隊", message: "請輸入小隊名", preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "小隊名"
            textField.keyboardType = UIKeyboardType.default
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let squadName = controller.textFields?[0].text ?? "新小隊"
            self.model.addNewBrevoSquad(title: squadName)
            self.SafeControlTableView.reloadData()
            print("新增\(squadName)小隊成功")
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var addNewSquadBtnOutlet: UIButton!
    
    @IBAction func fakeLoginFireman(_ sender: UIBarButtonItem) {
        model.fakeLogin(by: firecommandDB.fakeFireMansUUID[0])
        print(model.getBravoSquads())
    }
    
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
        
        self.addNewSquadBtnOutlet.layer.borderWidth = 1
        self.addNewSquadBtnOutlet.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        if UIDevice.current.orientation.isLandscape{
            self.divideBy = 5.0
        }
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
        
        if segue.identifier == "segueToLogPageV2"{
            let destinationtoAdd = segue.destination as! SafeControlLogV2ViewController
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
    
    // 選擇跟取消選擇要跟ＭＯＤＥＬ連動
    // 一進入就觸發第一個cell 選擇
    // 點擊cell之後 --> 把被點擊的選擇＝true
    // 找地方觸發把先前的cell的選擇=false
    // 重繪
    // 選擇 --> 存入moldel
    // ** 注意 因為現在整張表格全部都用來顯示bravoSquads 所以表格的index才能跟bravoSquads陣列中的index對上
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BravoSquadTableViewCell") as! BravoSquadTableViewCell
        
        let bravoSquads = model.getBravoSquads()
        
        // 為了找出正在被選擇的squad準備
//        var ii:IndexPath = IndexPath(row: 0, section: 0)
//
//        let selectedSquadIndex = model.getSelectedSquad().index
//        ii.row = selectedSquadIndex
        
        // 遍歷所有bravoSquad，找出isSelected＝ture的，把他的index存入ii
//        for (index, element) in bravoSquads.enumerated(){
//            if element.isSelected == true{
//                ii.row = index
//            }
//        }
//        print("ii=\(ii),ii.row=\(ii.row)")
        // 根據剛剛的index 「選取」該bravoSquad cell
//        tableView.selectRow(at: ii, animated: true, scrollPosition: .none)
        // 選取跟改變裡面的文字是兩回事，所以要靠cell裡面的func setBravoSquad 來設定外觀文字
        if model.selectionStatus.currentRow == indexPath.row{
            cell.setBravoSquad(bravoSquad: bravoSquads[indexPath.row], isSelected: true)
        }else{
            cell.setBravoSquad(bravoSquad: bravoSquads[indexPath.row], isSelected: false)
        }
        print(model.getBravoSquads())
        // 關閉預設的選取樣式
        cell.selectionStyle = .none
        return cell
    }
    
    // TODO: 選擇cell 之後 嗶嗶都要進入這小隊
    // 選擇 --> 調用model的func把該squad的.isSelected 改為true --> 會自動觸發下面的取消選擇
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.model.selectBravoSquad(by: indexPath.row)
        model.didSelect(row: indexPath.row)
        print(model.getBravoSquads())
//        let cell = tableView.cellForRow(at: indexPath) as? BravoSquadTableViewCell
//        cell?.selectedSquad()
        self.SafeControlTableView.reloadData()
    }
    
    // 取消選擇 --> 調用model的func把該squad的.isSelected 改為false
    // **注意！ .reloadData()必須寫在這邊 因為 .reloadData()之後所有selected都會被取消掉，寫在別處就會無法觸發此delegate func
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("有觸發取消選取-- 取消選取了\(indexPath.row)")
//        self.model.deSelectBravoSquad(by: indexPath.row)
        
//        let cell = tableView.cellForRow(at: indexPath) as? BravoSquadTableViewCell
//        self.SafeControlTableView.reloadData()
    }
    
    // MARK: 設定動態cell的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let cell = tableView.cellForRow(at: indexPath) as? BravoSquadTableViewCell{
//        let bravoSquad = model.getBravoSquads()[indexPath.row]
//        print("condition:\(cell.ppp.count)")
        
        // 根據現在平版狀態直向橫向來給出可能要變更的行高
        NotificationCenter.default.addObserver(self, selector: #selector(self.didOrientationChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // 有Ｘ數量小隊 index.row 從row[0] ~ row[x-1] 都用來顯示小隊，最後一個顯示按鈕
//        if indexPath.row < model.getBravoSquads().count{
        // 計算現在小隊中有多少人用來計算顯示需要的行數(計算用的數字都是float才能無條件進位)
            let firemansInbravoSquad = Float(model.getBravoSquads()[indexPath.row].fireMans.count)
            var rows = ceil(firemansInbravoSquad / divideBy)
            if rows < 1{
                rows = 1
            }
        print("目前一行可以放\(divideBy)個，此cell有\(rows)行")
        return CGFloat(rows*440)
//        }else{
//            return 90
//        }
    }
    
}

extension SafeControlViewController:SafeControlModelDelegate{
    func bleStatus(status: String) {
        if status == "已連線"{
            self.bluetoothStatus.image = #imageLiteral(resourceName: "home_bluetooth_connected")
        }else if status == "藍芽未開啟"{
            self.bluetoothStatus.image = #imageLiteral(resourceName: "home_bluetooth_unconnected")
        }else{
            self.bluetoothStatus.image = #imageLiteral(resourceName: "home_bluetooth_connecting")
        }
    }
    
    func dataDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.SafeControlTableView.reloadData()
            print("更新資料by Model delegate & 已執行 -- reloadData")
        
        }
    }
}
