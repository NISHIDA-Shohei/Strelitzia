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
    
    func getHistory() -> Observable<HistoryData> {
        return model.getHistory().asObservable()
    }
    
    func uploadSurveyData(title: String, place: String, details: String, image: UIImage) -> Observable<ResultAlert> {
        return model.uploadSurveyData(title: title, place: place, details: details, image: image).asObservable()
    }
    
    func getSurveyData(documentId: String) -> Observable<SurveyData> {
        return model.getSurveyData(documentId: documentId).asObservable()
    }
    
    func uploadEditedSurveyData(documentId: String, title: String, place: String, details: String, image: UIImage) -> Observable<ResultAlert> {
        return model.uploadEditedSurveyData(documentId: documentId, title: title, place: place, details: details, image: image).asObservable()
    }
}
