//
//  ViewController.swift
//  camera01
//
//  Created by Satoru Ohguchi on 2019/07/10.
//  Copyright © 2019年 Satoru Ohguchi. All rights reserved.
//
//

import UIKit
import AWSS3

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet var cameraView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // カメラ機能起動
    @IBAction func startCamera(_ sender : AnyObject) {
        let sourceType:UIImagePickerController.SourceType =
            UIImagePickerController.SourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerController.SourceType.camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }

    // 撮影が完了した時に呼ばれる
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage]
            as? UIImage {
            
            cameraView.contentMode  = .scaleAspectFit
            cameraView.image    =   pickedImage
        }
        
        // 閉じる
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // S3にファイルを保存
    @IBAction func savePicture(_ sender : AnyObject) {
        let image:UIImage! = cameraView.image
        if image != nil {
            uploadData(image)
        }
    }
    
    func uploadData(_ uploadImage: UIImage) {
        // Documentsディレクトリの絶対パス
        let transferUtility = AWSS3TransferUtility.default()
        let url = generateImageUrl(uploadImage)
        let bucket = "ta-kh-201907-menu"
        let contentType = "image/jpeg"
        
        // アップロード中の処理
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                // Do something e.g. Update a progress bar.
            }
        }
        
        // アップロード後の処理
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async {
                // Do something e.g. Alert a user for transfer completion.
                // On failed uploads, `error` contains the error object.
            }
        }
        
        // アップロード
        transferUtility.uploadFile(
            url,
            bucket: bucket,
            key: "images/upload.jpg",
            contentType: contentType,
            expression: expression,
            completionHandler: completionHandler
            ).continueWith { (task) -> Any? in
                if let error = task.error as NSError? {
                    print("localizedDescription:\n\(error.localizedDescription)")
                    print("userInfo:\n\(error.userInfo)")
                }
                if let _ = task.result {
                    // Do something with uploadTask.
                }
                return nil
        }
    }
    
    func generateImageUrl(_ uploadImage: UIImage) -> URL {
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory().appendingFormat("upload.jpg"))
        if let jpegData = uploadImage.jpegData(compressionQuality: 1) {
            try! jpegData.write(to: imageURL, options: [.atomicWrite])
        }
        return imageURL
    }
}
