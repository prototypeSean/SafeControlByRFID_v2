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
import Firebase

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
    
    // MARK: IBOutlet
    @IBOutlet weak var SafeControlTableView: UITableView!
    
    @IBOutlet weak var bluetoothStatus: UIImageView!
    
    @IBAction func reNameBLENFCDevice(_ sender: UIBarButtonItem) {
        model.reNameBLENFCDevide()
    }
    
    @IBOutlet weak var addNewSquad: UIButton!

    @IBOutlet weak var allowEditSquad: UIButton!
    

    
    //MARK: IBAction
    
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
            for (squad,man) in self.allSelectedFiremans{
                self.model.deSelectedFireman(in: squad, place: man)
            }
            self.allSelectedFiremans.removeAll()
            print("新增\(squadName)小隊成功")
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    //在某個cell按下「移入」人員
    @IBAction func moveFiremanTo(_ sender: UIButton) {

        // 用神奇的方法抓取是哪個row(也就是bravoSquad)被按下了，之後要移入
        let buttonPosition = sender.convert(CGPoint.zero, to: self.SafeControlTableView)
        let indexPath = self.SafeControlTableView.indexPathForRow(at: buttonPosition)
        if indexPath != nil {
            print("按下的按鈕是第幾行\(indexPath!.row)")
        }
        
        self.model.reArrengementSquad(into: indexPath!.row, selectedList: self.allSelectedFiremans)
        
        self.allSelectedFiremans.removeAll()

        self.SafeControlTableView.reloadData()
    }
    
    // 按下設定隊長按鈕
    @IBAction func startSettingCapBtn(_ sender: UIButton) {
        // 用神奇的方法抓取是哪個row(也就是bravoSquad)被按下了，之後要移入
        let buttonPosition = sender.convert(CGPoint.zero, to: self.SafeControlTableView)
        let clickedRow = self.SafeControlTableView.indexPathForRow(at: buttonPosition)?.row
        
        // 現在model中存的 cell是否可以選擇隊長狀態
        var isSettingCaptain = self.model.getBravoSquads()[clickedRow!].isSettingCap
        if !isSettingCaptain{
            print("ROW\(clickedRow!) 開始設定隊長")
            self.model.startSettingCap(at: clickedRow!)
            isSettingCaptain = true
        }else{
            print("ROW\(clickedRow!) 結束設定隊長")
            self.model.endSettingCap(at: clickedRow!)
            isSettingCaptain = false
            self.SafeControlTableView.reloadData()
        }
        
        // 關掉編輯隊員的功能
        self.allowEdit = false
        allowEditSquad.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        allowEditSquad.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 0.5)
        self.allSelectedFiremans.removeAll()
        self.SafeControlTableView.reloadData()
    }
    
    
    
    // 開始編輯小隊按鈕
    @IBAction func allowEditSquadBtn(_ sender: UIButton) {
        
        // 兩個功能只能同時存在一個 要把選隊長功能關掉
        for squad in 0..<self.model.getBravoSquads().count{
            self.model.endSettingCap(at: squad)
            print(self.model.getBravoSquads()[squad])
        }
        
        if allowEdit{
            allowEdit = false
            allowEditSquad.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            allowEditSquad.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 0.5)
        }else{
            allowEdit = true
            allowEditSquad.tintColor = #colorLiteral(red: 0.1725490196, green: 0.1960784314, blue: 0.2431372549, alpha: 1)
            allowEditSquad.backgroundColor = UIColor.white
        }
        for (squad,man) in self.allSelectedFiremans{
            self.model.deSelectedFireman(in: squad, place: man)
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
    
    //MARK: FireBase 遠端資料庫
    var docRef: DocumentReference? = nil
    lazy var firedb = Firestore.firestore()
    
    struct firemanToFB {
        let name: String
    }
    
    
    
//    // 建立 Docuement 同時插入資料
    func testFirebasedb(){
        let dataToSafe = ["name": self.model.getBravoSquads()[0].fireMans[0].name ]
        docRef = firedb.document("userCollection/使用者000")
        docRef?.setData(dataToSafe){ (error) in
            if let error = error {
                print("新增資料錯誤\(error.localizedDescription)")
            }else{
                print("新增資料成功")
            }
        }
    }
    
    @IBAction func firebaseTest(_ sender: UIBarButtonItem) {
        testFirebasedb()
        print("Fire!\(String(describing: docRef?.documentID))")
//        let dataSaveToFireBase:[String:Any] = ["capName": "隊長名"]
//        docRef?.setData(dataSaveToFireBase) { (error) in
//            if let error = error{
//                print("有錯誤喔\(error)")
//            }else{
//                print("資料存進去\(self.docRef!.documentID)了")
//            }
//
//        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        var docRef: DocumentReference? = nil
//        let firedb = Firestore.firestore()
//        docRef = Firestore.firestore().document("userCollection/fireman")
        docRef = firedb.document("userCollection/使用者001")
        
        // 建立DB連線
        firecommandDB = FirecommandDatabase()
        firecommandDB.createTableFireman()
        
        
        if UIDevice.current.orientation.isLandscape{
            self.divideBy = 5.0
        }else if UIDevice.current.orientation.isPortrait{
            self.divideBy = 4.0
        }
        
        // 編排人員的時候要把該按鈕反白高光
        let allowEditImage = #imageLiteral(resourceName: "home_switch_member").withRenderingMode(.alwaysTemplate)
        allowEditSquad.setImage(allowEditImage, for: .normal)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        
        // 可以選取人員時候的設定
        if self.allowEdit{
            cell.firemanCollectionView.allowsMultipleSelection = true
            cell.moveFiremanHere?.isHidden = false
        }
        else{
            cell.firemanCollectionView.allowsSelection = false
            cell.firemanCollectionView.allowsMultipleSelection = false
            cell.moveFiremanHere?.isHidden = true
        }
        
        let bravoSquads = model.getBravoSquads()
        
        // 選取跟改變裡面的文字是兩回事，所以要靠cell裡面的func setBravoSquad 來設定外觀文字
        if model.selectionStatus.currentRow == indexPath.row{
            cell.setBravoSquad(bravoSquad: bravoSquads[indexPath.row], isSelected: true)
        }else{
            cell.setBravoSquad(bravoSquad: bravoSquads[indexPath.row], isSelected: false)
        }

        cell.selectionStyle = .none
        
        
        // 設定隊長按鈕外觀

        
        if (bravoSquads[indexPath.row].fireMans.first(where: {$0.isLeader == true})) != nil{
            
            cell.capName.text = bravoSquads[indexPath.row].capName
            print("這是第\(indexPath.row)行，隊長是，隊長是\(String(describing: cell.capName.text))")
            cell.capCallSign.text = bravoSquads[indexPath.row].capCallSign
            cell.setCapBtnOutletOn()
        }else{
            cell.setCapBtnOutletOff()
            cell.capName.text = "隊長名"
            cell.capCallSign.text = "設定隊長"
        }


        return cell
    }
    
    // TODO: 選擇cell 之後 嗶嗶都要進入這小隊
    // 選擇 --> 調用model的func把該squad的.isSelected 改為true --> 會自動觸發下面的取消選擇
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        model.didSelect(row: indexPath.row)

        // 要不要重置整個選取事件呢？
//        self.allSelectedFiremans.removeAll()
//        self.allowEdit = false
//        allowEditSquad.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        allowEditSquad.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 0.5)
        
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
//        print("目前一行可以放\(divideBy)個，此cell有\(rows)行")
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

// MARK: collectionViewCell 的代理 選取之後把人傳回這個ＶＣ
extension SafeControlViewController:SelectedFiremanDelegate{
    
    // 取消選取隊長（換隊長的時候觸發）
    func deSetCaptain(selectedCap: (row: Int, item: Int)) {
    }
    
    // 設定隊長模式
    func setCaptain(selectedCap selectedFireman: (row: Int, item: Int)) {
        self.model.selectedCaptainToModel(in: selectedFireman.row, place: selectedFireman.item)
        self.SafeControlTableView.reloadData()
    }
    
    
    // 在選取模式點下了某個消防員 傳進此處的陣列
    func addFiremanToChangeSquadList(selectedFireman: (row: Int, item: Int)) {
        self.allSelectedFiremans.append(selectedFireman)
        
        self.model.selectedFireman(in: selectedFireman.row, place: selectedFireman.item)
//        print("代理被選擇的人\(selectedFireman.row)\(selectedFireman.item)")
        print("全部\(model.getBravoSquads())")
    }
    
    // 同上 取消選取某消防員
    func removeFiremanToChangeSquadList(selectedFireman: (row: Int, item: Int)) {
        self.allSelectedFiremans.removeAll(where: {$0 == selectedFireman})
        
        self.model.deSelectedFireman(in: selectedFireman.row, place: selectedFireman.item)
        
        print("有人被取消選取之後\(self.allSelectedFiremans)")
    }
}
