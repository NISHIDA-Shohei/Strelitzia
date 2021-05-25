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
    
    func getHistory() -> Observable<HistoryData> {
        return Observable.create { [weak self] observer in
            let folderRef = self?.ref.collection("survey").whereField("userId", isEqualTo: self?.userId ?? "")
            folderRef?.getDocuments {(snapshot, error) in
                if error != nil {
                    print("Document does not exist")
                } else {
                    for document in (snapshot?.documents)! {
                        let id = document.documentID
                        guard let title = document.data()["title"] as? String else { return }
                        guard let lastModifiedTimestamp = document.data()["lastModified"] as? Timestamp else { return }
                        guard let isCompleated = document.data()["isCompleated"] as? Bool else { return }
                        guard let imageURL = document.data()["imageURL"] as? String else { return }
                        let lastModified = lastModifiedTimestamp.dateValue()
                        let data = HistoryData(documentId: id, title: title, lastModified: lastModified, isCompleated: isCompleated, imageURL: imageURL)
                        observer.onNext(data)
                    }
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

struct HistoryData {
    var documentId: String
    var title: String
    var lastModified: Date
    var isCompleated: Bool
    var imageURL: String
    
    init(documentId: String, title: String, lastModified: Date, isCompleated: Bool, imageURL: String) {
        self.documentId = documentId
        self.title = title
        self.lastModified = lastModified
        self.isCompleated = isCompleated
        self.imageURL = imageURL
    }
}
