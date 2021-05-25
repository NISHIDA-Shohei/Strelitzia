//
//  UserMainViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/23.
//

import UIKit
import RxSwift
import RxCocoa

class UserMainViewController: UIViewController {
    
    private let viewModel = UserViewModel()
    private let disposeBag = DisposeBag()
    
    private var userInfo = UserInfo(isAdmin: Bool(), schoolId: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getUserInfo()
    }
    
    @IBAction func onTapNewSurvey(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        let surveyViewController = storyboard.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
        self.present(surveyViewController, animated: true, completion: nil)
    }
    func getUserInfo() {
        viewModel.getUserInfo()
            .subscribe(onNext: { [weak self] response in
                self?.userInfo.schoolId = response.schoolId
                self?.userInfo.isAdmin = response.isAdmin
            }).disposed(by: disposeBag)
    }
}
