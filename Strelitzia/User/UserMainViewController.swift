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
    
    private let viewModel = UserViewModel()
    private let disposeBag = DisposeBag()
    
    private var userInfo = UserInfo(isAdmin: Bool(), schoolId: "")
    
    var historyData = [HistoryData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
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
                self?.getHistory()
            }).disposed(by: disposeBag)
    }
    
    func getHistory() {
        viewModel.getHistory()
            .subscribe(onNext: { [weak self] response in
                self?.historyData.append(response)
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
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
        cell.statusLabel.text = historyData[indexPath.item].isCompleated ? "対応済み" : "未対応"
        cell.statusLabel.textColor = historyData[indexPath.item].isCompleated ? UIColor.green : UIColor.red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let selectedId = userDefaults.string(forKey: "selectedId") else { return }
//        let detailViewController = UINib(nibName: "ProgramDetailViewController", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ProgramDetailViewController
//        detailViewController.getDetailProgram(festivalId: selectedId, programId: programData[indexPath.row].id, type: type)
//        self.present(detailViewController, animated: true, completion: nil)
    }
}