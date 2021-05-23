//
//  UserModel.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/23.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

class UserModel {
    
    private var ref = Firestore.firestore()
    private let userId = Auth.auth().currentUser?.uid

    func getUserInfo() -> Observable<UserInfo> {
        return Observable.create { observer in
            let folderRef = self.ref.collection("users").document(self.userId!)
            folderRef.getDocument {(document, error) in
                if let document = document, document.exists {
                    let isAdmin = document.get("isAdmin") as? Bool
                    let schoolId = document.get("schoolId") as? String ?? ""
                    
                    let userInfo = UserInfo(isAdmin: isAdmin!, schoolId: schoolId)
                    observer.onNext(userInfo)

                } else {
                    print("Document does not exist")
                }
            }
            return Disposables.create()
        }
    }
}

struct UserInfo {
    var isAdmin: Bool
    var schoolId: String
    
    init(isAdmin: Bool, schoolId: String) {
        self.isAdmin = isAdmin
        self.schoolId = schoolId
    }
}
