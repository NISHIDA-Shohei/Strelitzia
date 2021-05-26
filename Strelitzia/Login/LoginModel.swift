//
//  LoginModel.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/26.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

class LoginModel {
    
    private var ref = Firestore.firestore()
    
    func checkIsAdmin(userId: String) -> Observable<Bool> {
        return Observable.create { observer in
            let folderRef = self.ref.collection("users").document(userId)
            folderRef.getDocument {(document, error) in
                if let document = document, document.exists {
                    let isAdmin = document.get("isAdmin") as? Bool
                    observer.onNext(isAdmin!)
                } else {
                    print("Document does not exist")
                }
            }
            return Disposables.create()
        }
    }
}
