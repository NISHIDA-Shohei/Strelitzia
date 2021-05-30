//
//  AdminMenuViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/26.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase

class AdminMenuViewController: UIViewController {
    
    @IBOutlet weak var schoolIdLabel: UILabel!
    @IBOutlet weak var schoolNameTextField: UITextField!
    
    private let viewModel = AdminViewModel()
    private let disposeBag = DisposeBag()
    
    private var userDefaults = UserDefaults.standard
    
    fileprivate let refreshCtl = UIRefreshControl()
    
    var historyData = [HistoryData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
    }
    
    func getUserInfo() {
        viewModel.getUserInfo()
            .subscribe(onNext: { [weak self] response in
                self?.schoolIdLabel.text = response.schoolId
                self?.getSchoolInfo(schoolId: response.schoolId)
            }).disposed(by: disposeBag)
    }
    
    func getSchoolInfo(schoolId: String) {
        viewModel.getSchoolInfo(schoolId: schoolId)
            .subscribe(onNext: { [weak self] response in
                self?.schoolNameTextField.text = response.schoolName
            }).disposed(by: disposeBag)
    }
    
    
    @IBAction func tapUpdateButton() {
        viewModel.changeSchoolInfo(schoolId: schoolIdLabel.text!, schoolName: schoolNameTextField.text ?? "")
            .subscribe(onNext: { [weak self] response in
                if response == false { //送信に失敗した場合
                    self?.showAlert(title: "エラーが起きました", text: "時間を空けてもう一度お試しください")
                }
            }).disposed(by: disposeBag)
    }
    
    @IBAction func onTapLogoutButton() {
        do {
            try Auth.auth().signOut()
            let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginViewController.modalPresentationStyle = .fullScreen
            self.present(loginViewController, animated: false, completion: nil)
        } catch {
            print("ログアウトできない")
        }
    }

    @IBAction func onTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title:String, text: String = "") {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion:nil)
    }
    
}
