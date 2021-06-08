//
//  SurveyViewController.swift
//  StrelitziaClip
//
//  Created by 西田翔平 on 2021/06/07.
//

import UIKit
import Firebase

class ClipSurveyViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!

    let functions = ClipFunctions()
    private var ref = Firestore.firestore()
    var schoolId: String!
    var userId: String!

    var isEditingView = false
    var documentId = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        schoolId = "HmiKOwU1"
        userId = "clipsUser"

        imageView.layer.cornerRadius = 20
        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidAppear(_ animated: Bool) {
        selectButton.blueTheme()
        sendButton.blueTheme()
    }

    @IBAction func onTapSelectImage(_ sender: Any) {
        selectImage()
    }

    @IBAction func onTapUploadSurvey(_ sender: Any) {
        guard let title = titleTextField.text else { return }
        guard let place = placeTextField.text else { return }
        guard let detail = detailsTextView.text else { return }
        guard let image = imageView.image else { return }

        functions.startIndicator(view: self.view)
        sendSurvey(title: title, place: place, detail: detail, image: image)
    }

    @IBAction func onTapClose() {
        dismiss(animated: true, completion: nil)
    }
}


extension ClipSurveyViewController {

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

        alert.popoverPresentationController?.sourceView = self.view

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

    func sendSurvey(title: String, place: String, detail: String, image: UIImage ) {
        guard let imageData = image.jpegData(compressionQuality: 0.01) else {
            showAlert(title: "画像の圧縮に失敗しました", text: "時間を空けてもう一度お試しください")
            functions.dismissIndicator(view: self.view)
            return
        }

        let metaData = StorageMetadata()
        metaData.contentType = "image/ipeg"

        let imageID = NSUUID().uuidString // Unique string to reference image
        let imageRef = Storage.storage().reference(forURL: "gs://strelitzia-8e9cf.appspot.com").child(imageID)

        DispatchQueue.global(qos: .default).async {
            imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
                if error != nil {
                    self.showAlert(title: "画像の保存に失敗しました", text: "時間を空けてもう一度お試しください")
                    self.functions.dismissIndicator(view: self.view)
                }

                imageRef.downloadURL { (url, error) in
                    if error != nil {
                        self.showAlert(title: "画像のパス取得に失敗しました", text: "時間を空けてもう一度お試しください")
                        self.functions.dismissIndicator(view: self.view)
                    } else {
                        let newFolder: [String: Any] = [
                            "userId": self.userId,
                            "title": title,
                            "place": place,
                            "details": detail,
                            "imageURL": url?.absoluteString as Any,
                            "imageReference": imageID,
                            "isCompleted": false,
                            "pointReceived": false,
                            "lastModified": Timestamp()
                        ]

                        self.ref.collection("school").document(self.schoolId).collection("survey").addDocument(data: newFolder) { error in
                            DispatchQueue.main.async {
                                if error != nil {
                                    self.showAlert(title: "エラーが起きました", text: "時間を空けてもう一度お試しください")
                                } else {
                                    self.showAlert(title: "送信に成功しました", text: "")
                                }
                                self.functions.dismissIndicator(view: self.view)
                            }
                        }
                    }
                }
            }
        }
    }
}
