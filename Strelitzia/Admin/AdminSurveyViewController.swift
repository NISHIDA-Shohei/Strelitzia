//
//  AdminSurveyViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/26.
//

import UIKit
import RxSwift
import RxCocoa

class AdminSurveyViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    private let viewModel = AdminViewModel()
    private let disposeBag = DisposeBag()
    
    let functions = Functions()
    
    let schoolId = UserDefaults.standard.string(forKey: "schoolId") ?? ""
    
    var documentId = ""
    var isCompleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.textColor = UIColor.white
        statusLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        imageView.layer.cornerRadius = 20
        detailsTextView.isEditable = false
    }
    
    @IBAction func onTapStatusButton(_ sender: Any) {
        changeStatus()
    }

    @IBAction func onTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    func changeStatus() {
        viewModel.changeStatus(schoolId: schoolId, documentId: documentId, isCompleted: isCompleted)
            .subscribe(onNext: { [weak self] response in
                if response { //送信に成功した場合
                    self?.isCompleted = !self!.isCompleted
                    self?.changeStatusButton()
                } else { //送信に失敗した場合
                    self?.showAlert(title: "エラーが起きました", text: "時間を空けてもう一度お試しください")
                }
            }).disposed(by: disposeBag)
    }
    
    func getSurveyData() {
        viewModel.getSurveyData(schoolId: schoolId, documentId: documentId)
            .subscribe(onNext: { [weak self] response in
                self?.imageView.loadImageAsynchronously(url: response.imageURL)
                self?.titleLabel.text = response.title
                self?.placeLabel.text = response.place
                self?.detailsTextView.text = response.details
                self?.isCompleted = response.isCompleted
                self?.changeStatusButton()
            }).disposed(by: disposeBag)
    }
    
    func changeStatusButton() {
        if self.isCompleted {
            self.statusButton.greenTheme()
            self.statusLabel.text = "対応済み"
        } else {
            self.statusButton.redTheme()
            self.statusLabel.text = "未対応"
        }
    }
    
    func showAlert(title:String, text: String = "") {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion:nil)
    }

}
