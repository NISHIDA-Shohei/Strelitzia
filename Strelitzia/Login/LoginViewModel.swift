//
//  LoginViewModel.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/26.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    private let model = LoginModel()
    
    func checkIsAdmin() -> Observable<Bool> {
        return model.checkIsAdmin().asObservable()
    }
}
