//
//  LoginViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/22.
//

import UIKit
import Firebase
import FirebaseUI
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    var functions = Functions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.text = "user1@gmail.com"
        self.passwordTextField.text = "user11"
        
    }
    
    @IBAction func onTapLogin(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        functions.startIndicator(view: self.view)
        DispatchQueue.global(qos: .default).async {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if (result?.user) != nil {
                        self.decideView(userId: result!.user.uid)
                    }
                    self.functions.dismissIndicator(view: self.view)
                }
                self.showErrorIfNeeded(error)
            }
        }
    }
    
    func decideView(userId: String) {
        viewModel.checkIsAdmin(userId: userId)
            .subscribe(onNext: { [weak self] response in
                if response {
                    print("true")
                }
                if response == true {
                    print("admin")
                    let storyboard: UIStoryboard = UIStoryboard(name: "Admin", bundle: nil)
                    let adminMainViewController = storyboard.instantiateViewController(withIdentifier: "AdminMainViewController") as! AdminMainViewController
                    adminMainViewController.modalPresentationStyle = .fullScreen
                    self?.present(adminMainViewController, animated: false, completion: nil)
                } else {
                    print("user")
                    let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
                    let userMainViewController = storyboard.instantiateViewController(withIdentifier: "UserMainViewController") as! UserMainViewController
                    userMainViewController.modalPresentationStyle = .fullScreen
                    self?.present(userMainViewController, animated: false, completion: nil)
                }
                
            }).disposed(by: disposeBag)
    }
    
    private func showErrorIfNeeded(_ errorOrNil: Error?) {
        // エラーがなければ何もしません
        guard let error = errorOrNil else { return }
        
        let message = errorMessage(of: error) // エラーメッセージを取得
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func errorMessage(of error: Error) -> String {
        var message = "エラーが発生しました"
        guard let errcd = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }
        
        switch errcd {
        case .networkError: message = "ネットワークに接続できません"
        case .userNotFound: message = "ユーザが見つかりません"
        case .invalidEmail: message = "不正なメールアドレスです"
        case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
        case .wrongPassword: message = "入力した認証情報でサインインできません"
        case .userDisabled: message = "このアカウントは無効です"
        case .weakPassword: message = "パスワードが脆弱すぎます"
        // これは一例です。必要に応じて増減させてください
        default: break
        }
        return message
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
