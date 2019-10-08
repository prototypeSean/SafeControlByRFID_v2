//
//  PhotoManager.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/9/3.
//  Copyright © 2019 DennisKao. All rights reserved.
//  

import UIKit



protocol PhotoPathJustSaved {
    func getPhotoPath(photoPath:URL)
}
// 1.用來存取照片 把image存到檔案路徑
// 2.用來讀取照片 (讓RFID作為檔名？)
class PhotoManager: NSObject {
    var delegate: PhotoPathJustSaved?
    // 把照片存進ios本地
    
    override init() {
        super.init()
    }
    
    func saveImageToDocumentDirectory(image: UIImage, filename:String) -> URL?{
        var dicExit: ObjCBool = true
        let mainPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        // 自定義路徑名稱
        let folderPath = mainPath + "/firecommandPhotos/"
        // 路徑不存在就創造資料夾 （晚點縮寫成if let）
        let folderExist = FileManager.default.fileExists(atPath: folderPath, isDirectory: &dicExit)
        if !folderExist {
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                print("路徑不存在，新增路徑\(folderPath)")
            } catch {
                print(error)
            }
        }
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageName = "\(filename).png"
        let imageUrl = documentDirectory.appendingPathComponent("firecommandPhotos/\(imageName)")
        if let data = image.jpegData(compressionQuality: 1.0){
            do {
                try data.write(to: imageUrl)
                print("照片儲存成功")
                return imageUrl
                self.delegate?.getPhotoPath(photoPath: imageUrl)
            } catch {
                print("error saving", error)
            }
        }
        return nil
    }
    
    // 讀取照片
    func loadImageFromDocumentDirectory(filename : String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("firecommandPhotos/\(filename)")
            // 如果取出image是 nil 就顯示這個
            guard let image = UIImage(contentsOfFile: imageURL.path) else { return  UIImage.init(named: "ImageInApp")!}
//            print("嘗試讀取照片\(imageURL)")
            return image
        }
        return UIImage.init(named: "ImageInApp")!
    }
}
