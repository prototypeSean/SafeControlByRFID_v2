import Foundation
import UIKit

class SafeControlLogPageViewController:UIViewController{
    @IBOutlet weak var safeControlEnterLogTableView: UITableView!
    @IBOutlet weak var safeControlLeaveLogTableView: UITableView!
    private var model:SafeControlModel?
    
    var sections:(enter:[String],exit:[String])=([],[])
    var finalArrayEnter:Array<FiremanForLog>=[]
    var finalArrayLeave:Array<FiremanForLog>=[]

    
    @IBAction func reload(_ sender: UIBarButtonItem) {
//        countSections()
//        makeSectionCell(logSectionCase: .enter)
//        model?.firemanDB.allfiremanForLogPage()
//        print("\(finalArrayEnter)")
//        print("\(finalArrayLeave)")
//        finalArrayEnter = (model?.firemanDB.makeSectionCellEnter)!
//        finalArrayLeave = (model?.firemanDB.makeSectionCellExit)!
        model?.firemanDB.sortAllfiremanForLogPage()
        self.finalArrayEnter = (self.model?.firemanDB.makeSectionCellEnter)!
        self.finalArrayLeave = (self.model?.firemanDB.makeSectionCellExit)!
        self.safeControlEnterLogTableView.reloadData()
        self.safeControlLeaveLogTableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        safeControlEnterLogTableView.delegate = self
        safeControlEnterLogTableView.dataSource = self
        safeControlEnterLogTableView.restorationIdentifier = "enter"
        safeControlLeaveLogTableView.delegate = self
        safeControlLeaveLogTableView.dataSource = self
        safeControlLeaveLogTableView.restorationIdentifier = "leave"
        
        self.model?.firemanDB.allfiremanForLogPage()
        self.model?.firemanDB.sortAllfiremanForLogPage()
        self.finalArrayEnter = (self.model?.firemanDB.makeSectionCellEnter)!
        self.finalArrayLeave = (self.model?.firemanDB.makeSectionCellExit)!
//        model?.firemanDB.allfiremanForLogPage()
//        sections = countSections()
    }
    
    // 邪門的delegate用法在這
    func setupModel(model:SafeControlModel){
        self.model = model
        model.delegateForLog = self
    }
}

extension SafeControlLogPageViewController:UITableViewDelegate, UITableViewDataSource{
    
    // 計算每個section有多少行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.restorationIdentifier == "enter"{
//            print("model?.logEnter\(String(describing: model?.logEnter))")
            print("計算每個區域有多少row-- in\(section) = \(finalArrayEnter[section].fireman.count)")
            
            return finalArrayEnter[section].fireman.count
//            return self.makeSectionCell(logSectionCase: .enter)[section].man.count
//            return model?.logEnter.count ?? 0
        }
//        print("model?.logLeave\(String(describing: model?.logLeave))")
        print("計算每個區域有多少row-- exit\(finalArrayLeave[section].fireman.count)")
        return finalArrayLeave[section].fireman.count
//        return model?.logLeave.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.restorationIdentifier == "enter"{
//            let ee = countSections().enter
//            print("進入表格有幾區\(ee.count)")
            return finalArrayEnter.count
        }
        else{
//            let ee = countSections().exit
//            print("撤離表格有幾區\(ee.count)")
//            return ee.count
            return finalArrayLeave.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = UIColor.clear
//        let viewLabel = UILabel(frame: CGRect(x: 0, y: 0, width:
//            tableView.bounds.size.width, height: tableView.bounds.size.height))
//        viewLabel.sizeToFit()
//        if tableView.restorationIdentifier == "enter"{
//            viewLabel.text = sections.enter[section]
//        }else{
//            viewLabel.text = sections.exit[section]
//        }
//        viewLabel.textColor = UIColor.white
//        view.addSubview(viewLabel)
//        return view
        let headerView = UIView()
        headerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1001712329)
//        headerView.layer.borderWidth = 1
//        headerView.addBorderBottom(size: 1.0, color: UIColor.red)
        
        
        let headerLabel = UILabel(frame: CGRect(x: 30, y: 5, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        
        headerLabel.textColor = UIColor.white
//        headerLabel.addBorderBottom(size: 2.0, color: UIColor.white)
        if tableView.restorationIdentifier == "enter"{
            headerLabel.text = finalArrayEnter[section].dayOnSection
        }else{
            headerLabel.text = finalArrayLeave[section].dayOnSection
        }
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
        
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if tableView.restorationIdentifier == "enter"{
//            let entSectionTitle = sections.enter[section]
//            return entSectionTitle
//        }else{
//            return sections.exit[section]
//        }
//    }
    
    
    // 具體定義每個cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogTableViewCell", for: indexPath) as! SafeControlLogTableViewCell
        
        if tableView.restorationIdentifier == "enter"{
//            cell.setFireman(fireman: model!.logEnter[indexPath.row])
            cell.status.text = "進"
//            let e = makeSectionCell(logSectionCase: .enter)
//            cell.setFireman(fireman: e[indexPath.section].man[indexPath.row])
            // TODO: setFireman 有點耗資源的感覺
            cell.setFireman(fireman: finalArrayEnter[indexPath.section].fireman[indexPath.row])
            // 臨時外觀設定
            // let cellMarginViewHeight = cell.marginView.layer.bounds.height
            cell.marginView.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.clear
            //這行被下一行的複寫了 暫時不知道該用啥顏色
            cell.marginView.backgroundColor = #colorLiteral(red: 1, green: 0.4039215686, blue: 0.1882352941, alpha: 1)
            cell.marginView.backgroundColor = UIColor.clear
            cell.marginView.addBottomBorder(color: UIColor.white, margins: 5, borderLineSize: 1.0
            )
            // 臨時外觀設定
//            cell.setColorSetting(colorSetting: .Enter)
//            cell.contentView.layer.borderWidth = 2
//            cell.contentView.layer.cornerRadius = 15
        }else{
            cell.setFiremanOut(fireman: finalArrayLeave[indexPath.section].fireman[indexPath.row])
//            let e = makeSectionCell(logSectionCase: .enter)
//            cell.setFireman(fireman: e[indexPath.section].man[indexPath.row])
            cell.status.text = "出"
            // 臨時外觀設定
//            let cellMarginViewHeight = cell.marginView.layer.bounds.height
            cell.marginView.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.clear
            cell.marginView.addBottomBorder(color: UIColor.white, margins: 5, borderLineSize: 1.0
            )
            // 同上 外觀都暫時的
            cell.marginView.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.968627451, blue: 0.8549019608, alpha: 1)
            cell.marginView.backgroundColor = UIColor.clear
            // 臨時外觀設定
//            cell.setColorSetting(colorSetting: .Leave)
        }
        return cell
    }
    // MARK:這裡有一堆計算陣列跟時間的要做成筆記或入庫
    // 要要製作區分每天的section
    // 需要計算出有幾天->才知道有幾個section header
    // 計算log裡面總共有哪些日期
    

    
    enum logSectionCase {
        case enter
        case exit
    }
    
    /// 目標是得到整個logTableView要顯示多少 Section (日期)；
    /// DB 已經分類存了[進入]跟[離開]火場的欄位,並分別做成logEnter/logLeave兩種 <FiremanForBravoSquad> 陣列
    /// 所以這邊針對 logEnter logLeave 做整理來取出目標為兩個陣列「進入有哪些天」「出來有哪些天」
//    func countSections() -> (enter:[String],exit:[String]){
//        var entersSection:Array<String> = []
//        var leavesSection:Array<String> = []
//
//        // 最後要用的東西
//        var entersSectionString:[String] = []
//        var leavesSectionString:[String] = []
//        for ffbs in self.model!.logEnter{
//            // 逐個把時間戳轉成日期->找出有幾天
//            let tpIn = Double(ffbs.timestamp)!
//            let dateInString = timeStampToString(timestamp: tpIn, theDateFormat: "YYYY-MM-dd")
//            //  print("\(ffbs.name) 的 進入年月日 \(dateInString)")
//            entersSection.append(dateInString)
//        }
//        // logLeave 已經是只有“離開”時間戳的bravoSquad了
//        for ffbs in self.model!.logLeave{
//            let tpOut = Double(ffbs.timestampout)!
//            let dateInString = timeStampToString(timestamp: tpOut, theDateFormat: "YYYY-MM-dd")
//            // print("\(ffbs.name) 的 進入年月日 \(dateInString)")
//            leavesSection.append(dateInString)
//        }
//
//        // 用純文字的陣列來移除重複日期 NSOrderedSet 比起set 多了會保留原本順序的特性(而且比較快？)
//        entersSection = Array(NSOrderedSet(array: entersSection)) as! Array<String>
//        leavesSection = Array(NSOrderedSet(array: leavesSection)) as! Array<String>
//
//        // 把剩下的陣列存回date型態 等下要用來依日期重新排序
//        var convertedArrayIn: [Date] = []
//        var convertedArrayOut: [Date] = []
//        let dateFormatter2 = DateFormatter()
//        dateFormatter2.dateFormat = "YYYY-MM-dd"
//
//        for d in entersSection {
//            let date = dateFormatter2.date(from: d)
//            if let date = date {
//                convertedArrayIn.append(date)
//            }
//        }
//        for d in leavesSection {
//            let date = dateFormatter2.date(from: d)
//            if let date = date {
//                convertedArrayOut.append(date)
//            }
//        }
//        // 照日期降序排 這也能拿來用其實 只是型態不是字串
//        let resultIn = convertedArrayIn.sorted(by: { $0.compare($1) == .orderedDescending })
//        let resultOut = convertedArrayOut.sorted(by: { $0.compare($1) == .orderedDescending })
//
//        // 最後一個for了..轉成字串
//        for rin in resultIn{
//            entersSectionString.append(dateFormatter2.string(from: rin))
//        }
//        for rOut in resultOut{
//            leavesSectionString.append(dateFormatter2.string(from: rOut))
//        }
//
////        print("全部的進入日期 \(entersSectionString)\n全部的撤離日期 \(leavesSectionString)\n")
//        return (entersSectionString,leavesSectionString)
//    }
    
//    func makeSectionCell(logSectionCase:logSectionCase) -> Array<(day:String,man:[FiremanForBravoSquad])>{
//        // 製作整個 LogTableView 最後輸出的格式 <日：[人人人]>
//        var makeSectionCellEnt:Array<(day:String,man:[FiremanForBravoSquad])>=[]
//        var makeSectionCellExi:Array<(day:String,man:[FiremanForBravoSquad])>=[]
//        // 依序填入日期
//        switch logSectionCase {
//        case .enter:
//            for entSection in sections.enter{
//                makeSectionCellEnt.append((entSection,[]))
//                // 從log裡面撈出日期一樣的填入FFBS
//            }
//            print("只有日期的makeSectionCellEnter\(makeSectionCellEnt)")
//            for eachEntlog in model!.logEnter{
//                let d = Double(eachEntlog.timestamp)
//                let date = timeStampToString(timestamp: d!, theDateFormat: "YYYY-MM-dd")
//                // 檢查日期有沒有對上 對上就把人插進去
//                if let index = makeSectionCellEnt.firstIndex(where:{$0.day == date}) {
//                    makeSectionCellEnt[index].man.append(eachEntlog)
//                }
//            }
//            return makeSectionCellEnt
//        case .exit:
//            for entSection in sections.exit{
//                makeSectionCellExi.append((entSection,[]))
//                // 從log裡面撈出日期一樣的填入FFBS
//            }
//            for eachEntlog in model!.logLeave{
//                let d = Double(eachEntlog.timestampout)
//                let date = timeStampToString(timestamp: d!, theDateFormat: "YYYY-MM-dd")
//                if let index = makeSectionCellExi.firstIndex(where:{$0.day == date}) {
//                    makeSectionCellExi[index].man.append(eachEntlog)
//                }else{
//                    print("撤出日期不合")
//                }
//            }
//            return makeSectionCellExi
//        }
//    }
}

extension SafeControlLogPageViewController:SafeControlModelDelegate{
    func dataDidUpdate() {
        DispatchQueue.main.async {
//            self.model?.firemanDB.allfiremanForLogPage()
            self.finalArrayEnter.removeAll()
            self.finalArrayLeave.removeAll()
            self.model?.firemanDB.sortAllfiremanForLogPage()
            self.finalArrayEnter = (self.model?.firemanDB.makeSectionCellEnter)!
            self.finalArrayLeave = (self.model?.firemanDB.makeSectionCellExit)!
            self.safeControlEnterLogTableView.reloadData()
            self.safeControlLeaveLogTableView.reloadData()
        }
    }
}
