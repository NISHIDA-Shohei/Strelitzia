//
//  SurveyViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/25.
//

import UIKit
import Firebase

class SurveyViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    
    let functions = Functions()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onTapSelectImage(_ sender: Any) {
        selectImage()
    }
    
    @IBAction func onTapUploadSurvey(_ senger: Any) {
        if let _ = titleTextField.text,
           let _ = placeTextField.text,
           let _ = detailsTextView.text,
           let _ = imageView.image {
            uploadData()
        }
    }
}


extension SurveyViewController {
    
    //MARK:- サーバーにアップロードする
    func uploadData() {
        functions.startIndicator(view: self.view)
        guard let imageData = self.imageView.image?.jpegData(compressionQuality: 0.01) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/ipeg"
        
        let imageID = NSUUID().uuidString // Unique string to reference image
        let folderRef = Firestore.firestore().collection("survey")
        let imageRef = Storage.storage().reference(forURL: "gs://strelitzia-8e9cf.appspot.com").child(imageID)
        
        DispatchQueue.global(qos: .default).async {
            imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
                if error != nil {
                    self.functions.dismissIndicator(view: self.view)
                    self.showAlert(title: "画像の保存に失敗しました", text: "時間を空けてもう一度お試しください")
                    return
                }
        
                imageRef.downloadURL { (url, error) in
                    if error != nil {
                        self.functions.dismissIndicator(view: self.view)
                        self.showAlert(title: "画像情報の保存に失敗しました", text: "時間を空けてもう一度お試しください")
                    } else {
                        let newFolder: [String: Any] = [
                            "userId": Auth.auth().currentUser?.uid ?? "",
                            "title": self.titleTextField.text!,
                            "place": self.placeTextField.text!,
                            "details": self.detailsTextView.text!,
                            "imageURL": url?.absoluteString as Any,
                            "imageReference": imageID,
                            "isCompleated": false,
                            "lastModified": Timestamp()
                        ]
                        
                        folderRef.addDocument(data: newFolder) { error in
                            DispatchQueue.main.async {
                                if error != nil {
                                    self.functions.dismissIndicator(view: self.view)
                                    self.showAlert(title: "エラーが発生しました", text: "時間を空けてもう一度お試しください")
                                } else {
                                    self.functions.dismissIndicator(view: self.view)
                                    self.showAlert(title: "保存されました")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showAlert(title:String, text: String = "") {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion:nil)
    }
    
    //MARK:- 画像を選択する
    func selectImage() {
        let alert: UIAlertController = UIAlertController(title: "", message: "選択してください", preferredStyle:  UIAlertController.Style.actionSheet)

        let cameraAction: UIAlertAction = UIAlertAction(title: "カメラで撮影", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.presentPickerController(sourceType: .camera)
        })
        let libraryAction: UIAlertAction = UIAlertAction(title: "アルバムから選択", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.presentPickerController(sourceType: .photoLibrary)
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "閉じる", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("cancelAction")
        })

        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
    func presentPickerController(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
    }
}


