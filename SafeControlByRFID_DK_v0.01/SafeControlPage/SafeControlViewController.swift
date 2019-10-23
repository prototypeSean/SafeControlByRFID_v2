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
        self.SafeControlTableView.reloadData()
    }
    
    var firecommandDB: FirecommandDatabase!

    let model = SafeControlModel()
    
    @IBOutlet weak var SafeControlTableView: UITableView!
    
    @IBOutlet weak var bluetoothStatus: UIImageView!
    
    @IBAction func reNameBLENFCDevice(_ sender: UIBarButtonItem) {
        model.reNameBLENFCDevide()
    }
    
    @IBOutlet weak var addNewSquad: UIButton!

    @IBOutlet weak var allowEditSquad: UIButton!
    
    //在某個cell按下「移入」人員
    @IBAction func moveFiremanTo(_ sender: UIButton) {
        var fmReadyToMove: Array<FiremanForBravoSquad> = []
        for (x,y) in allSelectedFiremans{
            let fireman = model.getBravoSquads()[x].fireMans[y]
            fmReadyToMove.append(fireman)
        }
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.SafeControlTableView)
        let indexPath = self.SafeControlTableView.indexPathForRow(at: buttonPosition)
        if indexPath != nil {
            print("按下的按鈕是第幾行\(indexPath!.row)")
        }
        
        
        print(fmReadyToMove)
    }
//    @IBOutlet weak var moveFiremanToBtn: UIButton!
    
    
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
            // 如果觸發了新增小隊的功能，要把之前選取的cell都取消掉
            self.allSelectedFiremans.removeAll()
            print("新增\(squadName)小隊成功")
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    // 開始編輯小隊按鈕
    @IBAction func allowEditSquadBtn(_ sender: UIButton) {
        if allowEdit{
            allowEdit = false
        }else{
            allowEdit = true
        }
        self.allSelectedFiremans.removeAll()
        self.SafeControlTableView.reloadData()
    }
    
    private var allowEdit:Bool = false
    
    var allSelectedFiremans:Array<(row:Int, item:Int)> = []
    
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
        
        
        if UIDevice.current.orientation.isLandscape{
            self.divideBy = 5.0
        }else if UIDevice.current.orientation.isPortrait{
            self.divideBy = 4.0
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
        
        //給出按下按鈕的是哪個cell
//        moveFiremanTo.tag = indexPath.row
//        moveFiremanToBtn.addTarget(self, action: Selector("moveFiremanTo"), for: UIControl.Event.touchUpInside)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BravoSquadTableViewCell") as! BravoSquadTableViewCell
        
        cell.delegate = self
        
        if self.allowEdit{
            cell.firemanCollectionView.allowsMultipleSelection = true
        }else{
            cell.firemanCollectionView.allowsSelection = false
            cell.firemanCollectionView.allowsMultipleSelection = false
        }
        
        let bravoSquads = model.getBravoSquads()
        
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
        return CGFloat(rows*420)
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

// collectionViewCell 的代理 選取之後把人傳回這個ＶＣ
extension SafeControlViewController:SelectedFiremanDelegate{
    
    func removeFiremanToChangeSquadList(selectedFiremans: (row: Int, item: Int)) {
        self.allSelectedFiremans.removeAll(where: {$0 == selectedFiremans})
        print("有被取消選取的人後\(self.allSelectedFiremans)")
    }
    
    func addFiremanToChangeSquadList(selectedFiremans: (row: Int, item: Int)) {
        self.allSelectedFiremans.append(selectedFiremans)
        print("全部被選取的人\(self.allSelectedFiremans)")
    }
    
}
