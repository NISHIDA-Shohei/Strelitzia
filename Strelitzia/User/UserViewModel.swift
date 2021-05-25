//
//  UserViewModel.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/23.
//

import Foundation
import RxSwift

class UserViewModel {
    private let model = UserModel()
    
    func getUserInfo() -> Observable<UserInfo> {
        return model.getUserInfo().asObservable()
    }
    
    func getHistory(schoolId: String) -> Observable<HistoryData> {
        return model.getHistory(schoolId: schoolId).asObservable()
    }
    
    func uploadSurveyData(schoolId: String, title: String, place: String, details: String, image: UIImage) -> Observable<ResultAlert> {
        return model.uploadSurveyData(schoolId: schoolId, title: title, place: place, details: details, image: image).asObservable()
    }
    
    func getSurveyData(schoolId: String, documentId: String) -> Observable<SurveyData> {
        return model.getSurveyData(schoolId: schoolId, documentId: documentId).asObservable()
    }
    
    func uploadEditedSurveyData(schoolId: String, documentId: String, title: String, place: String, details: String, image: UIImage) -> Observable<ResultAlert> {
        return model.uploadEditedSurveyData(schoolId: schoolId, documentId: documentId, title: title, place: place, details: details, image: image).asObservable()
    }
}
