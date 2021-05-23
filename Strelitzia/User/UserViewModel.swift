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
}
