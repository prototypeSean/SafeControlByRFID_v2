import Foundation
import UIKit

class SafeControlLogTableViewCell:UITableViewCell{

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var marginView: UIView!
    
    private let enterColor = #colorLiteral(red: 1, green: 0.4039215686, blue: 0.1882352941, alpha: 1)
    private let leaveColor = #colorLiteral(red: 0.3450980392, green: 0.968627451, blue: 0.8549019608, alpha: 1)
    enum ColorSetting {
        case Enter
        case Leave
    }
    var colorSetting:ColorSetting = .Enter
    
    // 把單一個cell要顯示的東西從FiremanForBravoSquad 分析出來
    func setFireman(fireman:FiremanForBravoSquad){
        self.name.text = fireman.name
        self.timestamp.text = getLatestedTimeStamp(fireman: fireman)
//        self.timestamp.text = fireman.timestamp.since1970ToString()
    }
    
    func setFiremanOut(fireman:FiremanForBravoSquad){
        self.name.text = fireman.name
        self.timestamp.text = getLatestedTimeStampOut(fireman: fireman)
        //        self.timestamp.text = fireman.timestamp.since1970ToString()
    }
    
    
//    func setFiremanForlogOut(fireman:FiremanForBravoSquad) {
//        self.name.text = fireman.name
//        self.timestamp.text = getLatestedTimeStamp(fireman: fireman)
//    }
    func setColorSetting(colorSetting:ColorSetting){
        switch colorSetting {
        case .Enter:
            self.backgroundColor = enterColor
        default:
            self.backgroundColor = leaveColor
        }
    }
}

extension TimeInterval{
    func since1970ToString() -> String{
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "HH:mm:ss"
        let date = Date(timeIntervalSince1970: self)
        return dateFormat.string(from: date)
    }
}
