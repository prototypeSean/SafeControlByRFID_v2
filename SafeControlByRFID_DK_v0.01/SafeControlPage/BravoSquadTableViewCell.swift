//
//  BravoSquadTableViewCell.swift
//  safe_control_by_RFID
//
//  Created by elijah tam on 2019/8/15.
//  Copyright © 2019 elijah tam. All rights reserved.
//

import Foundation
import UIKit

protocol SelectedFiremanDelegate {
    func addFiremanToChangeSquadList(selectedFireman:(row:Int, item:Int))
    func removeFiremanToChangeSquadList(selectedFireman:(row:Int, item:Int))

    func setCaptain(selectedCap:(row:Int, item:Int))
    func deSetCaptain(selectedCap:(row:Int, item:Int))
}

class BravoSquadTableViewCell:UITableViewCell{
    
    @IBOutlet weak var bravoSquadTitle: UILabel!
    @IBOutlet weak var bravoSquadSubTitle: UILabel!
    @IBOutlet weak var subTitleIcon: UIImageView!
    @IBOutlet weak var moveFiremanHere: UIButton!
    
    // 設定隊長的按鈕 長度跟底下的文字同長，圖示要另外設定填滿
    @IBOutlet weak var setCaptain: UIButton!

    @IBOutlet weak var capCallSign: UILabel!
    @IBOutlet weak var capName: UILabel!
    
    
    @IBOutlet weak var firemanCollectionView: UICollectionView!
    
    private var bravoSquad:BravoSquad?
    
    @IBOutlet weak var heightOfCollectionView: NSLayoutConstraint!
    
    var selectedFiremansIndex: Array<(row:Int, item:Int)> = []
    
    var delegate: SelectedFiremanDelegate?
    
    
    // MARK: 設定隊長 step: 1/3
    var isSelectingCaptain:Bool = false

    
//    var ppp:[String] = ["123","223","3","4"]
////    ,"4","5","6","7","8","9","10","11","12","13","14"
//    @IBAction func plus1fireman(_ sender: UIButton) {
//        ppp.append("++")
//        self.firemanCollectionView.reloadData()
//
//
//        // 文中的「4.Change the bottom equal constraint of the collection view to greater or equal.」沒用上才能作動
//        let height:CGFloat = self.firemanCollectionView.collectionViewLayout.collectionViewContentSize.height
//        heightOfCollectionView.constant = height
//        self.firemanCollectionView.layoutIfNeeded()
//    }
    

    
    // TODO:-- 沒用xib這行有用？暫時放著不管
    override func awakeFromNib() {
        super.awakeFromNib()
        firemanCollectionView.delegate = self
        firemanCollectionView.dataSource = self
        self.subTitleIcon.isHidden = true
     
        let moveFiremanHereImage = #imageLiteral(resourceName: "home_move_in_fireman").withRenderingMode(.alwaysTemplate)
        self.moveFiremanHere.setImage(moveFiremanHereImage, for: .normal)
        self.moveFiremanHere.backgroundColor = UIColor.white
        self.moveFiremanHere.tintColor = #colorLiteral(red: 0.1725490196, green: 0.1960784314, blue: 0.2431372549, alpha: 1)
        
        self.setCapBtnOutletOff()
    }
    
    func setCapBtnOutletOn(){
        print("設定隊長按鈕外觀-- 開開")
        let image = #imageLiteral(resourceName: "firefighter_badge_2")
        self.setCaptain.setImage(image, for: .normal)
        self.setCaptain.imageView?.contentMode = .scaleAspectFit
    }
    func setCapBtnOutletOff(){
        print("設定隊長按鈕外觀-- 關")
        let image = #imageLiteral(resourceName: "firefighter_badge")
        self.setCaptain.setImage(image, for: .normal)
        self.setCaptain.imageView?.contentMode = .scaleAspectFit
    }
    
    // 給父層調整選擇ROW時外觀用
    func selectedSquad(){
        self.bravoSquadSubTitle.text = "請感應 RFID"
//        self.bravoSquadSubTitle.lblShadow(color: .white, radius: 5, opacity: 0.5)
        
        //MARK: 註解掉了但是有用的文字陰影設定
//        bravoSquadSubTitle.layer.shadowColor = UIColor.white.cgColor
//        bravoSquadSubTitle.layer.shadowRadius = 0
//        bravoSquadSubTitle.layer.shadowOpacity = 1
//        bravoSquadSubTitle.layer.shadowOffset = .zero
//        bravoSquadSubTitle.layer.masksToBounds = false
        
        self.bravoSquadSubTitle.textColor = #colorLiteral(red: 0.9647058824, green: 0.8039215686, blue: 0.431372549, alpha: 1)
        self.subTitleIcon.isHidden = false
        
    }

    func deSelectedSquad(){
        self.bravoSquadSubTitle.text = "點擊登錄此小隊"
        self.bravoSquadSubTitle.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.subTitleIcon.isHidden = true
    }
    
    // 設定 BravoSquad(ROW) 外觀
    func setBravoSquad(bravoSquad:BravoSquad, isSelected:Bool){
        self.bravoSquad = bravoSquad
        self.firemanCollectionView.reloadData()
        self.bravoSquadTitle.text = bravoSquad.squadTitle
        
        // 此ＲＯＷ被選取了
        if isSelected{
            self.selectedSquad()
        }else{
            self.deSelectedSquad()
        }
        
        
        // 找出隊長的名字
        
        // TODO:-- 抄來的 尚未解析
        // 讓collectoinView高度自動適應，這邊不知道原理，趕時間以後再研究
        // https://stackoverflow.com/a/42438709
        let height:CGFloat = self.firemanCollectionView.collectionViewLayout.collectionViewContentSize.height
        heightOfCollectionView.constant = height
        self.firemanCollectionView.layoutIfNeeded()
        
        if bravoSquad.fireMans.count > 0{
            // 移到最右邊？
            self.firemanCollectionView.scrollToItem(at: IndexPath(row: bravoSquad.fireMans.count-1, section: 0), at: .right, animated: true)
        }
    }
}

extension BravoSquadTableViewCell:UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.bravoSquad?.fireMans.count ?? 0
        return count > 5 ? count: 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = firemanCollectionView.dequeueReusableCell(withReuseIdentifier: "FiremanCollectionViewCell", for: indexPath) as! FiremanCollectionViewCell
        
        collectionView.tag = self.bravoSquad!.indexInTableView
        
        // 預設了十個格子 只有fireMans.count人數 超過人數的格子設為nil
        if self.bravoSquad?.fireMans.count ?? 0 <= indexPath.row{
            cell.setFireman(fireman: nil)
        }else{
            cell.setFireman(fireman: self.bravoSquad?.fireMans[indexPath.row])
        }
        
//        從父層的cellForRowAt indexPath來設定allowsMultipleSelection 連帶控制這邊勾勾符號出現與否
        if collectionView.allowsMultipleSelection == true{
            cell.selectedCheck.isHidden = false
            
            // 可以「編排人員」的時候要把「選擇隊長」的選項關掉
            cell.hideLeaderBadge()
        }
        else if self.bravoSquad!.isSettingCap{
            cell.selectedCheck.isHidden = true
            collectionView.allowsSelection = true
            cell.showLeaderBadge()
        }
        else{
            cell.selectedCheck.isHidden = true
            cell.hideLeaderBadge()
        }
        
        
        if let isleader = self.bravoSquad?.fireMans[safe:indexPath.item]?.isLeader{
            if isleader{
                cell.isLeadeerBadge()
            }
        }
        
        return cell
    }
    
    // collectionView item 選取
    // 有兩種情況會觸發「開始選人」代理，要分開處理ＭＯＤＥＬ才不會亂（選人移動小隊 & 選隊長）
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 移動人員模式
        if collectionView.allowsMultipleSelection{
            // 沒有消防員的格子不觸發代理
            if (self.bravoSquad?.fireMans.count)! > indexPath.item{
                print("小隊\(collectionView.tag)\n被選上的消防員\(indexPath.item)")
                let row = collectionView.tag
                let item = indexPath.item
                //這邊傳入的只有一個cell的選擇
                self.delegate?.addFiremanToChangeSquadList(selectedFireman: (row,item))
                print("單cell被選擇的人\(String(describing: collectionView.indexPathsForSelectedItems))")
            }
        // 選隊長模式
        }else if self.bravoSquad!.isSettingCap{
            print("選隊長模式")
            if (self.bravoSquad?.fireMans.count)! > indexPath.item{
                print("小隊\(collectionView.tag)\n被選上的隊長\(indexPath.item)")
                let row = collectionView.tag
                let item = indexPath.item
                
                print("單cell被選擇隊長\(String(describing: collectionView.indexPathsForSelectedItems))")
                self.delegate?.setCaptain(selectedCap: (row,item))
            }
        }
    }
    
    // collectionView item 取消選取
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.allowsMultipleSelection{
            if (self.bravoSquad?.fireMans.count)! > indexPath.item{
                let row = collectionView.tag
                let item = indexPath.item
                //這邊傳入的只有一個cell的選擇
                self.delegate?.removeFiremanToChangeSquadList(selectedFireman: (row,item))
            }
        }else if self.bravoSquad!.isSettingCap{
            print("選隊長模式")
            if (self.bravoSquad?.fireMans.count)! > indexPath.item{
                print("小隊\(collectionView.tag)\n被選上的消防員\(indexPath.item)")
                let row = collectionView.tag
                let item = indexPath.item
            }
        }
    }
    
    
}
