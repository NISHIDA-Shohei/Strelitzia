//
//  UserMenuViewController.swift
//  Strelitzia
//
//  Created by papc-0370 on 2021/05/30.
//  Copyright (c) 2021, Phone Appli. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase
import FirebaseUI

class UserMenuViewController: UIViewController {

    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!

    private let viewModel = UserViewModel()
    private let disposeBag = DisposeBag()

    private var userInfo = UserInfo(isAdmin: Bool(), schoolId: "")
    private var userDefaults = UserDefaults.standard


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
        updatePointLabel()
    }

    @IBAction func onTapResetPointButton() {
        userDefaults.setValue(0, forKey: "point")
        updatePointLabel()
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

    func getUserInfo() {
        viewModel.getUserInfo()
            .subscribe(onNext: { [weak self] response in
                self?.userInfo.schoolId = response.schoolId
                self?.userInfo.isAdmin = response.isAdmin
                self?.getSchoolInfo(schoolId: response.schoolId)
            }).disposed(by: disposeBag)
    }

    func getSchoolInfo(schoolId: String) {
        viewModel.getSchoolInfo(schoolId: schoolId)
            .subscribe(onNext: { [weak self] response in
                self?.schoolNameLabel.text = response.schoolName
            }).disposed(by: disposeBag)
    }

    func updatePointLabel() {
        let currentPoint = self.userDefaults.object(forKey: "point") as? Int ?? 0
        pointLabel.text = String(currentPoint)
    }

    @IBAction func onTapClose() {
        dismiss(animated: true, completion: nil)
    }
}
