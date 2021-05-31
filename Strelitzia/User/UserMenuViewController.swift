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
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var resetPointButton: UIButton!
    
    private let viewModel = UserViewModel()
    private let disposeBag = DisposeBag()

    var userInfo = UserInfo(isAdmin: Bool(), schoolId: "")
    private var userDefaults = UserDefaults.standard
    
    var historyData = [UserHistoryData]()
    var schoolId = ""

    override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
        updatePointLabel()
        checkPoint()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        logoutButton.redTheme()
        resetPointButton.redTheme()
    }

    @IBAction func onTapResetPointButton() {
        userDefaults.setValue(0, forKey: "\(schoolId)point")
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
    
    func checkPoint() {
        for data in historyData {
            if data.isCompleted && !data.pointReceived {
                viewModel.changePointStatus(schoolId: userInfo.schoolId, documentId: data.documentId)
                    .subscribe(onNext: { [weak self] response in
                        if response { //ポイント状態の変更に成功
                            var currentPoint = self?.userDefaults.object(forKey: "\(self!.schoolId)point") as? Int ?? 0
                            print("point added")
                            currentPoint += 100
                            self?.userDefaults.setValue(currentPoint, forKey: "\(self!.schoolId)point")
                            self?.updatePointLabel()
                        }
                    }).disposed(by: disposeBag)
            }
        }
    }

    func updatePointLabel() {
        let currentPoint = self.userDefaults.object(forKey: "\(schoolId)point") as? Int ?? 0
        pointLabel.text = String(currentPoint)
    }

    @IBAction func onTapClose() {
        dismiss(animated: true, completion: nil)
    }
}
