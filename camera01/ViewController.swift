//
//  ViewController.swift
//  camera01
//
//  Created by Satoru Ohguchi on 2019/07/10.
//  Copyright © 2019年 Satoru Ohguchi. All rights reserved.
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
            // S3の保存処理
            

        }
    }
    
    func uploadImage(_ uploadImage: UIImage) {
        let transferManager = AWSS3TransferUtility.default()
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "your S3 bucket name"
        uploadRequest?.key = "your file name on S3"
        uploadRequest?.body = generateImageUrl(uploadImage)
        transferManager.upload(uploadRequest ?? <#default value#>).continueWith(block: { (task: AWSTask) -> Any? in
            if task.error != nil || task.description != nil {
                // エラー
            }
            return nil
        })
    }
    
    private func generateImageUrl(_ uploadImage: UIImage) -> URL {
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory().appendingFormat("upload.jpg"))
        if let jpegData = UIImageJPEGRepresentation(uploadImage, 80) {
            try! jpegData.write(to: imageURL, options: [.atomicWrite])
        }
        return imageURL
    }
}
