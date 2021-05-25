//
//  SurveyViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/25.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

class SurveyViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    
    private let viewModel = UserViewModel()
    private let disposeBag = DisposeBag()
    
    let functions = Functions()
    
    var isEditingView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isEditing {
            
        }
    }
    
    @IBAction func onTapSelectImage(_ sender: Any) {
        selectImage()
    }
    
    @IBAction func onTapUploadSurvey(_ senger: Any) {
        if let title = titleTextField.text,
           let place = placeTextField.text,
           let detail = detailsTextView.text,
           let image = imageView.image {
            functions.startIndicator(view: self.view)
            viewModel.uploadSurveyData(title: title, place: place, details: detail, image: image)
                .subscribe(onNext: { [weak self] response in
                    self?.showAlert(title: response.title, text: response.text)
                    self?.functions.dismissIndicator(view: (self?.view)!)
                }).disposed(by: disposeBag)
        }
    }
    
    func getSurveyData(documentId: String) {
        viewModel.getSurveyData(documentId: documentId)
            .subscribe(onNext: { [weak self] response in
                self?.imageView.loadImageAsynchronously(url: response.imageURL)
                self?.titleTextField.text = response.title
                self?.placeTextField.text = response.place
                self?.detailsTextView.text = response.details
            }).disposed(by: disposeBag)
    }
}


extension SurveyViewController {
    
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


