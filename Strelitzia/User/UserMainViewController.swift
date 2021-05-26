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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    
    private let viewModel = UserViewModel()
    private let disposeBag = DisposeBag()
    
    private var userInfo = UserInfo(isAdmin: Bool(), schoolId: "")
    private var userDefaults = UserDefaults.standard
    
    fileprivate let refreshCtl = UIRefreshControl()

    var historyData = [HistoryData]()
    
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
        self.present(surveyViewController, animated: true, completion: nil)
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
            }).disposed(by: disposeBag)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        getUserInfo()
        refreshCtl.endRefreshing()
    }
}

//MARK: - TableView
extension UserMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath as IndexPath) as! UserTableViewCell
        cell.titleLabel.text = historyData[indexPath.item].title
        cell.lastModifiedLabel.text = DateUtils.stringFromDate(date: historyData[indexPath.item].lastModified, dateFormat: "yyyy年MM月dd日")
        cell.thumbnailImage.loadImageAsynchronously(url: historyData[indexPath.item].imageURL)
        cell.statusLabel.text = historyData[indexPath.item].isCompleted ? "対応済み" : "未対応"
        cell.statusLabel.textColor = historyData[indexPath.item].isCompleted ? UIColor.green : UIColor.red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        let surveyViewController = storyboard.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
        surveyViewController.isEditingView = true
        surveyViewController.documentId = historyData[indexPath.item].documentId
        surveyViewController.getSurveyData()
        
        self.present(surveyViewController, animated: true, completion: nil)
    }
}
