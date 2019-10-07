//
//  BravoSquadTableViewCell.swift
//  safe_control_by_RFID
//
//  Created by elijah tam on 2019/8/15.
//  Copyright © 2019 elijah tam. All rights reserved.
//

import Foundation
import UIKit

class BravoSquadTableViewCell:UITableViewCell{
    @IBOutlet weak var firemanCollectionView: UICollectionView!
    private var bravoSquad:BravoSquad?
    
    @IBOutlet weak var heightOfCollectionView: NSLayoutConstraint!
    
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
    }
    
    
    
    func setBravoSquad(bravoSquad:BravoSquad){
        self.bravoSquad = bravoSquad
        self.firemanCollectionView.reloadData()
        
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
//        return count
//        return ppp.count
        return count > 1 ? count:1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = firemanCollectionView.dequeueReusableCell(withReuseIdentifier: "FiremanCollectionViewCell", for: indexPath) as! FiremanCollectionViewCell
        // 預設了十個格子 只有fireMans.count人數 超過人數的格子設為nil
        if self.bravoSquad?.fireMans.count ?? 0 <= indexPath.row{
            cell.setFireman(fireman: nil)
        }else{
            cell.setFireman(fireman: self.bravoSquad?.fireMans[indexPath.row])
        }
        return cell
    }
    
    override func didAddSubview(_ subview: UIView) {
        print("123")
    }
}
