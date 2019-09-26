//
//  BluetoothModel.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/8/28.
//  Copyright © 2019 DennisKao. All rights reserved.
//
//  此程式中，因為用途，所以我們設計連接的HC-08是外圍設備（Peripheral），
//  負責提供RFID的資訊給平板(Central)


import Foundation
import CoreBluetooth



protocol BluetoothModelDelegate {
    func didReciveRFIDDate(uuid:String)
}


class BluetoothModel:NSObject{
    
    // 為了singletion 設計的
    static let singletion = BluetoothModel()
    
    // 自己的
    var delegate:BluetoothModelDelegate?
    
    // ＳＤＫ的
    var bleManager: DKBleManager?
    var bleNfcDevice: DKBleNfcDevice?
    var mNearestBle: CBPeripheral?
    
    private override init() {
        super.init()
        
        self.bleManager = DKBleManager.sharedInstance()
        self.bleManager?.delegate = self
        self.bleNfcDevice = DKBleNfcDevice.init(delegate: self)
//        let centralQueue:DispatchQueue = DispatchQueue(label: "centralQueue")
//        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    // MARK:-- 給代理觸發後調用的func們
    // 找尋最近的藍牙外圍設備
    func findNearBle(){
        print("尋找藍牙")
        self.bleManager!.startScan()
        if (self.bleManager!.isScanning()){
            print("正在尋找外圍設備")
        }
    }
    
    // 取得藍芽裝置信息
    func getBLEDeviceMsg(){
        // 設備名稱
        let deviceName = self.bleNfcDevice?.getName()
//        self.textLog.text.append(contentsOf: "設備名稱：\(deviceName ?? "獲取設備名稱失敗")\n")
        print("設備名稱：\(deviceName ?? "獲取設備名稱失敗")")
        // TODO:--人家寫的getBatteryVoltage規定不能在主線程跑(.偶而會造成閃退因為NSException沒處理)
//        DispatchQueue.global(qos: .background).async {
//            let deviceBattery = self.bleNfcDevice?.getBatteryVoltage()
//            print("電池電壓：\(round(deviceBattery!*100)/100)")
//        }
    }
    
//    開啟 RFID 自動掃描功能
    func AutoScanRFID() {
        if !self.bleManager!.isConnect() {
//            self.textLog.text.append(contentsOf: "未連上藍牙")
            return
        }
        
//        let queueForRFIDScan:DispatchQueue = DispatchQueue(label: "AutoScanRFID",attributes: .concurrent)
        do{
            try ObjC.catchException{
                    if (self.bleNfcDevice?.startAutoSearchCard(20, cardType: UInt8(ISO14443_P3))) != nil{
                        print("等待感應RFID中...")
                    }else{
                        print("不支援自動感應")
                    }
            }
        }catch {
            print("該死的NSErrorrrrr\(error)")
        }
        
        // 不確定是不是因為丟到背景一直抱錯
//        DispatchQueue.global(qos: .background).async {
//            if (self.bleNfcDevice?.startAutoSearchCard(20, cardType: UInt8(ISO14443_P4))) != nil{
//                print("等待感應RFID中...")
//            }else{
//                print("不支援自動感應")
//            }
//        }
    }
    
    // 讀寫卡片 因爲不知道怎用swift抓NSUInteger 但是可以抓編號,所以貼過來看
    //    typedef NSUInteger DKCardType;
    //    NS_ENUM(DKCardType) {
    //    DKCardTypeDefault = 0,
    //    DKIso14443A_CPUType = 1,
    //    DKIso14443B_CPUType = 2,
    //    DKFeliCa_Type = 3,
    //    DKMifare_Type = 4,
    //    DKIso15693_Type = 5,
    //    DKUltralight_type = 6,
    //    DKDESFire_type = 7
    //    };
    func readWriteCard(cardType: DKCardType){
        switch cardType {
        // 趕時間只寫了case 4 理論上我們只用到m1卡
        case 4:
            print("讀取到 M1 卡")
            let mifare: Mifare = self.bleNfcDevice?.getCard() as! Mifare
            //TODO: %@ 是objc相容的東西 後面加了\r\n 的話下面去除尖括號的碼會失效
            let rawCardUID:String = NSString(format: "%@", mifare.uid! as CVarArg) as String
            let angleBracketsSet = CharacterSet(charactersIn: "<>")
            let cardUID = rawCardUID.trimmingCharacters(in: angleBracketsSet)
//            self.textLog.text.append(contentsOf: "uuid:\(String(describing: cardUID))\n")
            print("卡片uuid:\(String(describing: cardUID))")
            
            // 這邊把uuid傳出去這個model了
            self.delegate?.didReciveRFIDDate(uuid: cardUID)
        default:
            break
        }
    }
    
    
}

extension BluetoothModel: DKBleManagerDelegate, DKBleNfcDeviceDelegate{
    // 監聽本機藍牙狀態 -> 發現藍牙開啟 -> 觸發掃描func
    func dkCentralManagerDidUpdateState(_ central: CBCentralManager!) {
        switch central.state {
        case .unknown:
//            self.textLog.text.append(contentsOf: "本機藍牙未知狀態\n")
            print("未知狀態")
        case .resetting:
//            self.textLog.text.append(contentsOf: "本機藍牙重置中\n")
            print("重置中")
        case .unsupported:
//            self.textLog.text.append(contentsOf: "本機藍牙不支援\n")
            print("不支援")
        case .unauthorized:
//            self.textLog.text.append(contentsOf: "本機藍牙未驗證\n")
            print("未驗證")
        case .poweredOff:
//            self.textLog.text.append(contentsOf: "本機藍牙尚未啟動\n")
            print("尚未啟動")
        case .poweredOn:
//            self.textLog.text.append(contentsOf: "本機藍牙藍芽已開啟\n")
            print("藍芽已開啟")
            DispatchQueue.main.async {
                self.findNearBle()
            }
            
        @unknown default:
//            self.textLog.text.append(contentsOf: "unknown default\n")
            print("unknown default")
        }
    }
    
    // 開始掃描後監聽發現的外圍設備 -> 找到BLE_NFC之後掛上instance就連線
    func dkScannerCallback(_ central: CBCentralManager!, didDiscover peripheral: CBPeripheral!, advertisementData: [AnyHashable : Any]!, rssi RSSI: NSNumber!) {
        
        print("「發現外圍設備」的 delegate")
        
        if peripheral.name == "BLE_NFC"{
            print("找到 BLE_NFC")
            self.mNearestBle = peripheral
            self.bleManager?.connect(peripheral, callbackBlock: { (isConnected) in
                if isConnected{
                    print("連接BLE_NFC成功")
                    self.bleManager?.stopScan()
                    self.getBLEDeviceMsg()
                    
                    //連上設備就打開 RFID
//                    DispatchQueue.global(qos: .background).async {
//                        print("背景自動巡卡")
//                        self.AutoScanRFID()
//                    }

                }else{ print("連接失敗")}
            })
        }
    }
    
    // TODO: 斷線重連寫在這邊，尚未驗證是否會有問題
    func dkCentralManagerConnectState(_ central: CBCentralManager!, state: Bool) {
        print("ConnectState---- ")
        if state {
//            self.textLog.text.append(contentsOf: "與設備連線成功\n")
            print("與設備連線成功")
            let queueForRFIDScan:DispatchQueue = DispatchQueue(label: "AutoScanRFID")
            queueForRFIDScan.sync {
                self.AutoScanRFID()
            }
        }else{
//            self.textLog.text.append(contentsOf: "與設備連線失敗\n")
            print("與設備連線失敗")
            
            // 斷線重連
            DispatchQueue.main.async {
                self.bleManager!.connect(self.mNearestBle, callbackBlock: { (isconnected) in
                    if isconnected{
                        print("重新連接成功")
                    }
                    else{
                        print("重新連接失敗")
                    }
                })
            }
        }
    }
    
    // 讀到RFID 時啟動的delegate -> 觸發讀卡func
    func receiveRfnSearchCard(_ isblnIsSus: Bool, cardType: UInt, uid CardSn: Data!, ats bytCarATS: Data!) {
//        self.textLog.text.append(contentsOf: "讀取到卡片\n")
//        self.textLog.text.append(contentsOf: "卡片描述:\(CardSn.description)\n")
        
        self.readWriteCard(cardType: cardType)
    }
}

// ✡︎✡︎ 以下是搭配Arduino 的 HC-08 使用的舊程式碼
// 這是從藍牙硬體中讀到的UUID
//fileprivate let customService_UUID = CBUUID(string: "0xFFE0")
//fileprivate let customChatacteristic_UUID = CBUUID(string: "0xFFE1")
//
//// MARK: BluetoothModel 目前只有一個接口提供逼逼的 RFID 的 uuid
//protocol BluetoothModelDelegate {
//    func didReciveRFIDDate(uuid:String)
//}
//
//class BluetoothModel:NSObject{
//    var delegate:BluetoothModelDelegate?
//    var centralManager: CBCentralManager?
//    var customPeripheral: CBPeripheral?
//    var customCharacteristic:CBCharacteristic?
//
//    // 為了singletion 設計的
//    static let singletion = BluetoothModel()
//
//    private override init() {
//        super.init()
//        let centralQueue:DispatchQueue = DispatchQueue(label: "centralQueue")
//        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
//    }
//
//    func sendDataToRFID(data: Data){
//        customPeripheral?.writeValue(data, for: customCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
//        print(customPeripheral ?? "nil")
//    }
//}
//// BluetoothModel 要用來監控所有的藍芽狀態，所以吃CBCentralManagerDelegate來用
//// CBCentralManagerDelegate <-- 定義 CBCentralManager object 的代理必須符合的func . 其他提供選用的方法可用來監控外圍設備的掃描狀態，連線狀態，恢復狀態，唯一必須符合的方法是用來表示中心設備目前狀態，當中心設備的狀態改變時會被呼叫
////CBPeripheralDelegate <-- 提供func用來監控外圍設備的狀態
//extension BluetoothModel:CBCentralManagerDelegate,CBPeripheralDelegate{
//    func centralManagerDidUpdateState(_ central: CBCentralManager){
//        switch central.state {
//        case .unknown:
//            print("未知狀態")
//        case .resetting:
//            print("重置中")
//        case .unsupported:
//            print("不支援")
//        case .unauthorized:
//            print("未驗證")
//        case .poweredOff:
//            print("尚未啟動")
//        case .poweredOn:
//            print("啟動")
//            // 因為很多Service掃出來是nil 所以設定全掃(withServices: nil)
//            centralManager?.scanForPeripherals(withServices: nil, options: nil)
//        @unknown default:
//            print("未列入的新case")
//        }
//    }
//
//    // 發現藍牙設備的時候，把設備存到自己的變數裡,然後告訴center連上
//    // TODO: 確認是否能夠在沒連到指定設備時繼續掃描
//    // TODO: 之後要把設備名稱hc08寫成變數
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("peripheral name:\(String(describing: peripheral.name))")
//        print("service:\(String(describing: peripheral.services))")
//        // 如果設備名稱對上了就連線
//        if peripheral.name == "HC-08" {
//            self.customPeripheral = peripheral
//            centralManager?.connect(peripheral, options: nil)
//            print("已找到HC-08")
//        }
//    }
//    // 連接成功（連上hc-08）
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        // TODO: ??這邊用self.centralManager?.stopScan() 跟 central.stopScan() 差別在哪
//        // 連上之後就停止掃描
//        print("連上hc-08")
//        self.centralManager?.stopScan()
//        peripheral.delegate = self
//        customPeripheral?.discoverServices([customService_UUID])
//    }
//
//    // 連線失敗
//    // 這邊要不要讓他重連呢？.connect
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        print("連線失敗")
//    }
//
//    // 斷線重連
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        self.centralManager?.connect(peripheral, options: nil)
//    }
//
//    // -------上面都是 centralManager 的事 下面開始處理外圍設備 peripheral-------
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        for service in peripheral.services!{
//            print("發現service \(service)")
//            if service.uuid == customService_UUID{
//                print("UUID吻合")
//                // 為啥Ｅ寫nil 因為nil是全找
//                peripheral.discoverCharacteristics([customChatacteristic_UUID], for: service)
//            }
//        }
//    }
//
//    // 找到 characteristic 之後 --> 讀取服務裡面的值 --> 監聽該值的變化
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        for characteristic in service.characteristics!{
//            print("列出服務：\(characteristic)")
//            // 確認uuid是我們要找的
//            if characteristic.uuid == customChatacteristic_UUID{
//                // 第一次跑到這時應該是nil
//                print("服務中的value為：\(String(describing: characteristic.value))")
//                customCharacteristic = characteristic
//                peripheral.setNotifyValue(true, for: customCharacteristic!)
//            }
//        }
//    }
//
//    // 監聽狀態
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        if error != nil{
//            print("監聽失敗")
//            return
//        }
//        if characteristic.isNotifying{
//            print("監聽中")
//        }
//    }
//
//    // 接收數據 --> 檢查UUID正確 --> 把rfid_UUID資料寫進去
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        // 確認服務id是我們要的
//        guard characteristic.uuid == customChatacteristic_UUID else {return}
//        if let val = characteristic.value, let rfid_UUID = String(data: val, encoding: .utf8){
//            self.delegate?.didReciveRFIDDate(uuid: rfid_UUID)
//        }
//        else{
//            print("characteristic.uuid正確，但是讀取數據錯誤")
//        }
//    }
//}

// ✡︎✡︎ 以上是搭配Arduino 的 HC-08 使用的舊程式碼


