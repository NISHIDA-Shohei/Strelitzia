//
//  SplashViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/27.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

class SplashViewController: UIViewController {
    
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil {
            print("login")
            let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginViewController.modalPresentationStyle = .fullScreen
            self.present(loginViewController, animated: true, completion: nil)
        } else {
            let userId = Auth.auth().currentUser?.uid
            decideView(userId: userId!)
        }
    }
    
    func decideView(userId: String) {
        viewModel.checkIsAdmin(userId: userId)
            .subscribe(onNext: { [weak self] response in
                if response == true {
                    print("admin")
                    let storyboard: UIStoryboard = UIStoryboard(name: "Admin", bundle: nil)
                    let adminMainViewController = storyboard.instantiateViewController(withIdentifier: "AdminMainViewController") as! AdminMainViewController
                    adminMainViewController.modalPresentationStyle = .fullScreen
                    self?.present(adminMainViewController, animated: true, completion: nil)
                } else {
                    print("user")
                    let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
                    let userMainViewController = storyboard.instantiateViewController(withIdentifier: "UserMainViewController") as! UserMainViewController
                    userMainViewController.modalPresentationStyle = .fullScreen
                    self?.present(userMainViewController, animated: true, completion: nil)
                }
            }).disposed(by: disposeBag)
    }
}
