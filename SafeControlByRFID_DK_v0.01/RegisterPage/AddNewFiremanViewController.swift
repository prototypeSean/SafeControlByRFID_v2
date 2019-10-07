//
//  AddNewFiremanViewController.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/9/2.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import UIKit


// 一直忘記資料庫格式先貼來這裡方便看而已
//Table("table_fireman")
//table_FIREMAN_ID = Expression<Int64>("id")
//table_FIREMAN_SN = Expression<Int64>("serialNumber")
//table_FIREMAN_NAME = Expression<String>("firemanName")
//table_FIREMAN_PHOTO_PATH = Expression<String>("firemanPhotoPath")
//table_FIREMAN_CALLSIGN = Expression<String>("firemanCallsign")
//table_FIREMAN_RFIDUUID = Expression<String>("firemanRFID")
//table_FIREMAN_DEPARTMENT = Expression<String>("firemanDepartment")

// TODO: 1. 寫進資料庫的錯誤處理還沒做
// vTODO: 2. status bar 的顏色
// TODO: 3. 圖形化列出已經建檔的清單？
// TODO: 4. 點擊空白處收起鍵盤
// 這邊是由SafeComtrolelr轉跳而來的 要怎麼不跟他搶model的delegate ?


class AddNewFiremanViewController: UIViewController {
    
    var imagePicker: ImagePicker!
    var fireCommandDB: FirecommandDatabase?
    // 遷就而已 這邊之後應該要改掉 只是不想直接用藍芽model
    private var model: SafeControlModel?
    
    // MARK: IBOutlet區域
    @IBOutlet weak var fireManRFID: UILabel!
    @IBOutlet weak var fireManName: UITextField!
    @IBOutlet weak var firemanAvatar: UIImageView!
    @IBOutlet weak var serialNumber: UITextField!
    @IBOutlet weak var firemanCallSign: UITextField!
    @IBOutlet weak var firemanDepartment: UITextField!
    
    // 暫時區
    @IBAction func testingLog(_ sender: UIButton) {
        self.fireManRFID.text?.removeAll()
        print(fireCommandDB?.arrayEnter as Any)
        print(fireCommandDB?.arrayExit as Any)
    }
    
    // 暫時區
    
    var firemanTimeStamp:String?
    
    @IBOutlet weak var saveToDBOutlet: UIButton!
    
    @IBAction func saveToDB(_ sender: Any) {
        // 多一層彈出視窗 確認才寫入
        let controller = UIAlertController(title: "儲存消防員資料", message: "確認資料無誤", preferredStyle: .alert)
        // 利用 UIAlertAction 的第三個參數 handler 傳入的 closure 控制點選按鈕要做的事情。
        let okAction = UIAlertAction(title: "確認存入", style: .default){
            (_) in self.addCurrentFireMan()
            self.resetPageContent()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
    

    @IBAction func upDateFireman(_ sender: UIButton) {
        // 多一層彈出視窗 確認才寫入
        let controller = UIAlertController(title: "修改消防員資料", message: "確認資料無誤", preferredStyle: .alert)
        // 利用 UIAlertAction 的第三個參數 handler 傳入的 closure 控制點選按鈕要做的事情。
        let okAction = UIAlertAction(title: "確認存入", style: .default){
            (_) in self.upDateFireman()
            self.resetPageContent()
            self.upDateFiremanOutlet.isHidden = true
        }
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
    @IBOutlet weak var upDateFiremanOutlet: UIButton!
    
    func addCurrentFireMan(){
//        let currentTimeStamp = Date().timeIntervalSince1970
//        let currentTimeStampString = String(currentTimeStamp)
        fireCommandDB!.addNewFireman(
            serialNumber: serialNumber.text!,
            firemanName: fireManName.text!,
            firemanPhoto: self.firemanAvatar.image!,
            firemanCallsign: firemanCallSign.text!,
            firemanRFID: fireManRFID.text!,
            firemanTimeStamp: "",
            firemanTimeStampOut: "",
            firemanDepartment: firemanDepartment.text!)
    }
    
    func upDateFireman(){
        let ffr = FiremanForRegister(name: self.fireManName.text!,
                                     uuid: self.fireManRFID.text!,
                                     serialNumber: self.serialNumber.text!,
                                     callSing: self.firemanCallSign.text!,
                                     department: self.firemanDepartment.text!,
                                     image: self.firemanAvatar.image!)
        self.model?.firemanDB.updateFiremanForRegisterPage(by: ffr)
    }
    
    func resetPageContent(){
        self.firemanAvatar.image = UIImage(named: "ImagePlaceholder")
        self.firemanCallSign.text = ""
        self.serialNumber.text = ""
        self.fireManName.text = ""
        self.fireManRFID.text = "請感應卡片"
        self.firemanDepartment.text = ""
    }
    
    // 內部測試用 之後會拔掉 印出所有消防員
    @IBAction func printDB(_ sender: Any) {
        fireCommandDB?.allFireman()
    }
    
    // 呼叫Tools 裡面的照片選擇器
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    var recievedRFID:String?
    
    // MARK:-- 監聽各種裝置狀態(旋轉/鍵盤升起)，目前只有鍵盤升起的時候把view抬高
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        // 只有橫向＆＆鍵盤升起才需要抬高view
        if keyboardSize != nil && UIDevice.current.orientation.isLandscape{
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 110
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
//     監聽裝置旋轉
//    @objc func didOrientationChange(_ notification: Notification) {
//        print("other")
//        switch UIDevice.current.orientation {
//        case .landscapeLeft, .landscapeRight:
//            print("landscape")
//            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//        case .portrait, .portraitUpsideDown:
//            print("portrait")
//
//        default:
//            print("other")
//        }
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upDateFiremanOutlet.isHidden = true
//        BluetoothModel.singletion.delegate = self
//        model.delegateForAddFireman = self
        //MARK:-- 外觀設定
        self.firemanAvatar.layer.borderWidth = 2.0
        
        
        
        // 裝置打橫才需要抬升view
        if UIDevice.current.orientation.isLandscape{
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.didOrientationChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)

        
    
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        // 這邊把資料庫實體化（連線）用來把資料存進 DB
        fireCommandDB = FirecommandDatabase()
        
        // 暫時的 之後要做鍵盤跟ＲＦＩＤ
//        fireManName.text = "這是姓名"
//        serialNumber.text = "序號AA2234"
//        firemanCallSign.text = "隊員呼號222"
//        firemanDepartment.text = "隊員所屬分隊"
//        firemanTimeStamp = "16:05:44"
    }
///    轉跳過來的時候 把SafeControlVC的 Model借過來掛上delegate
    func setupModel(model:SafeControlModel){
        /// 這裡的self.model這裡的是private只能在這邊用
        self.model = model
        model.delegateForAddFireman = self
    }
    
    // 收到 RFID 之後顯示在 label.text
//    func didReciveRFIDDate(uuid: String) {
//        DispatchQueue.main.async {
//            self.fireManRFID.text=uuid
//        }
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// 吃下 ImagePickerDelegate 來顯示它拍攝或選擇的照片
extension AddNewFiremanViewController: CustomImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.firemanAvatar.image = image
//            ?? UIImage.init(named: "ImagePlaceholder")
        
    }
}

extension AddNewFiremanViewController: PhotoPathJustSaved{
    func getPhotoPath(photoPath: URL) {

    }
}

//extension AddNewFiremanViewController: BluetoothModelDelegate{
//
//}

extension AddNewFiremanViewController:SafeControldelegateforAddNewFireman{
    func newFiremanRFID(uuid: String) {
        DispatchQueue.main.async{
            print("註冊人員頁面的dataDidUpdate")
            
            if let fireman = self.model?.firemanDB.getFiremanforRegisterCheck(by: uuid){
                self.firemanAvatar.image = fireman.image
                self.firemanCallSign.text = fireman.callSing
                self.fireManName.text = fireman.name
                self.fireManRFID.text = uuid
                self.firemanDepartment.text = fireman.department
                self.serialNumber.text = fireman.serialNumber
                
                self.saveToDBOutlet.isHidden = true
                self.upDateFiremanOutlet.isHidden = false
                
            }else{
                self.resetPageContent()
                self.upDateFiremanOutlet.isHidden = true
                self.fireManRFID.text = "\(uuid)"
            }
        }
    }
}
