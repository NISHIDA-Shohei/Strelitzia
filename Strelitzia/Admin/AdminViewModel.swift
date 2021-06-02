//
//  AdminViewModel.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/26.
//

import Foundation
import RxSwift

class AdminViewModel {
    private let model = AdminModel()
    
    func getUserInfo() -> Observable<UserInfo> {
        return model.getUserInfo().asObservable()
    }
    
    func getHistory(schoolId: String) -> Observable<[HistoryData]> {
        return model.getHistory(schoolId: schoolId).asObservable()
    }
    
    func getSurveyData(schoolId: String, documentId: String) -> Observable<SurveyData> {
        return model.getSurveyData(schoolId: schoolId, documentId: documentId).asObservable()
    }
    
    func uploadEditedSurveyData(schoolId: String, documentId: String, title: String, place: String, details: String, image: UIImage) -> Observable<ResultAlert> {
        return model.uploadEditedSurveyData(schoolId: schoolId, documentId: documentId, title: title, place: place, details: details, image: image).asObservable()
    }
    
    func changeStatus(schoolId: String, documentId: String, isCompleted: Bool) -> Observable<Bool> {
        return model.changeStatus(schoolId: schoolId, documentId: documentId, isCompleted: isCompleted).asObservable()
    }
    
    func changeSchoolInfo(schoolId: String, schoolName: String) -> Observable<Bool> {
        return model.changeSchoolInfo(schoolId: schoolId, schoolName: schoolName)
    }
    
    func getSchoolInfo(schoolId: String) -> Observable<SchoolInfo> {
        return model.getSchoolInfo(schoolId: schoolId)
    }
    
}
