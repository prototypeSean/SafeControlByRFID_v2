//
//  ImagePicker.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/9/3.
//  Copyright © 2019 DennisKao. All rights reserved.
//
// 

import UIKit


public protocol CustomImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}


open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: CustomImagePickerDelegate?
    public init(presentationController: UIViewController, delegate: CustomImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        // 要告訴 Picker 從哪邊跳出視窗
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        // 這裡如果是true 之後在delegate的func中就要用.editedImage 而不是.originalImage
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "拍攝照片") {
            alertController.addAction(action)
        }
        // 因為不需“從相機膠卷選擇”所以註解掉
//        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
//            alertController.addAction(action)
//        }
        if let action = self.action(for: .photoLibrary, title: "選自相簿") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        // 為 iPad 多做的事
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

// 因為self.pickerController.delegate = self, 而 UIImagePickerController 的 delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? { get set }
extension ImagePicker: UINavigationControllerDelegate {

}
