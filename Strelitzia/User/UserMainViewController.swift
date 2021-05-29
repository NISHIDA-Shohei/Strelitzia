//
//  UserMainViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/23.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase
import FirebaseUI

class UserMainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    
    private let viewModel = UserViewModel()
    private let disposeBag = DisposeBag()
    
    private var userInfo = UserInfo(isAdmin: Bool(), schoolId: "")
    private var userDefaults = UserDefaults.standard
    
    fileprivate let refreshCtl = UIRefreshControl()
    
    var historyData = [UserHistoryData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(UserMainViewController.refresh(sender:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
    }
    
    @IBAction func onTapNewSurvey(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        let surveyViewController = storyboard.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
        self.present(surveyViewController, animated: false, completion: nil)
    }
    
    @IBAction func onTapPointReset() {
        userDefaults.setValue(0, forKey: "point")
        updatePointLabel()
    }
    
    @IBAction func onTapLogout() {
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
                self?.userDefaults.setValue(response.schoolId, forKey: "schoolId")
                self?.getSchoolInfo(schoolId: response.schoolId)
                self?.getHistory()
            }).disposed(by: disposeBag)
    }
    
    func getSchoolInfo(schoolId: String) {
        viewModel.getSchoolInfo(schoolId: schoolId)
            .subscribe(onNext: { [weak self] response in
                self?.schoolNameLabel.text = response.schoolName
            }).disposed(by: disposeBag)
    }
    
    func getHistory() {
        historyData = []
        viewModel.getHistory(schoolId: userInfo.schoolId)
            .subscribe(onNext: { [weak self] response in
                self?.historyData.append(response)
                self?.tableView.reloadData()
                self?.checkPoint()
            }).disposed(by: disposeBag)
    }
    
    func checkPoint() {
        for data in historyData {
            if data.isCompleted && !data.pointReceived {
                viewModel.changePointStatus(schoolId: userInfo.schoolId, documentId: data.documentId)
                    .subscribe(onNext: { [weak self] response in
                        if response { //ポイント状態の変更に成功
                            var currentPoint = self?.userDefaults.object(forKey: "point") as? Int ?? 0
                            currentPoint += 100
                            self?.userDefaults.setValue(currentPoint, forKey: "point")
                            self?.updatePointLabel()
                        }
                    }).disposed(by: disposeBag)
            }
        }
        updatePointLabel()
    }
    
    func updatePointLabel() {
        let currentPoint = self.userDefaults.object(forKey: "point") as? Int ?? 0
        pointLabel.text = String(currentPoint)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        getUserInfo()
        refreshCtl.endRefreshing()
    }
}

//MARK: - TableView
extension UserMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath as IndexPath) as! UserTableViewCell
        cell.titleLabel.text = historyData[indexPath.item].title
        cell.lastModifiedLabel.text = DateUtils.stringFromDate(date: historyData[indexPath.item].lastModified, dateFormat: "yyyy年MM月dd日 HH時mm分")
        cell.thumbnailImage.loadImageAsynchronously(url: historyData[indexPath.item].imageURL)
        cell.statusLabel.text = historyData[indexPath.item].isCompleted ? "対応済み" : "未対応"
//        cell.statusLabel.textColor = historyData[indexPath.item].isCompleted ? UIColor.green : UIColor.red
        cell.backgroundImageView.image = historyData[indexPath.item].isCompleted ? UIImage(named: "completeBackground") : UIImage(named: "incompleteBackground")

        cell.startColor = UIColor.init(named: "IncompleteStartColor")!
        cell.startColor = historyData[indexPath.item].isCompleted ? UIColor.init(named: "CompletedStartColor")! : UIColor.init(named: "IncompleteStartColor")!
        cell.endColor = historyData[indexPath.item].isCompleted ? UIColor.init(named: "CompletedEndColor")! : UIColor.init(named: "IncompleteEndColor")!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        let surveyViewController = storyboard.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
        surveyViewController.isEditingView = true
        surveyViewController.documentId = historyData[indexPath.item].documentId
        surveyViewController.getSurveyData()
        
        self.present(surveyViewController, animated: false, completion: nil)
    }
}
