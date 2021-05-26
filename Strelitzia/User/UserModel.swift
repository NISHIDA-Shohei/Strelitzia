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
    
    var schoolId = UserDefaults.standard.string(forKey: "schoolId")
    
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
    
    func getSchoolInfo(schoolId: String) -> Observable<SchoolInfo> {
        return Observable.create { observer in
            let folderRef = self.ref.collection("school").document(schoolId)
            folderRef.getDocument {(document, error) in
                if let document = document, document.exists {
                    let schoolName = document.get("schoolName") as? String ?? ""
                    let schoolId = document.get("schoolId") as? String ?? ""
                    let userInfo = SchoolInfo(schoolName: schoolName, schoolId: schoolId)
                    observer.onNext(userInfo)
                    
                } else {
                    print("Document does not exist")
                }
            }
            return Disposables.create()
        }
    }
    
    func getHistory(schoolId: String) -> Observable<UserHistoryData> {
        return Observable.create { [weak self] observer in
            let folderRef = self?.ref.collection("school").document(schoolId).collection("survey").whereField("userId", isEqualTo: self?.userId ?? "")
            folderRef?.getDocuments {(snapshot, error) in
                if error != nil {
                    print("Document does not exist")
                } else {
                    for document in (snapshot?.documents)! {
                        let id = document.documentID
                        guard let title = document.data()["title"] as? String else { return }
                        guard let lastModifiedTimestamp = document.data()["lastModified"] as? Timestamp else { return }
                        guard let isCompleted = document.data()["isCompleted"] as? Bool else { return }
                        guard let imageURL = document.data()["imageURL"] as? String else { return }
                        let pointReceived = document.data()["pointReceived"] as? Bool ?? false
                        let lastModified = lastModifiedTimestamp.dateValue()
                        let data = UserHistoryData(documentId: id, title: title, lastModified: lastModified, isCompleted: isCompleted, imageURL: imageURL, pointReceived: pointReceived)
                        observer.onNext(data)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func getSurveyData(schoolId: String, documentId: String) -> Observable<SurveyData> {
        return Observable.create { [weak self] observer in
            let folderRef = self?.ref.collection("school").document(schoolId).collection("survey").document(documentId)
            folderRef?.getDocument {(document, error) in
                if let document = document, document.exists {
                    let id = document.documentID
                    guard let title = document.data()?["title"] as? String else { return }
                    guard let place = document.data()?["place"] as? String else { return }
                    guard let details = document.data()?["details"] as? String else { return }
                    guard let imageURL = document.data()?["imageURL"] as? String else { return }
                    guard let isCompleted = document.data()?["isCompleted"] as? Bool else { return }
                    let data = SurveyData(documentId: id, title: title, place: place, details: details, imageURL: imageURL, isCompleted: isCompleted)
                    observer.onNext(data)
                } else {
                    print("Document does not exist")
                }
            }
            return Disposables.create()
        }
    }
    
    func uploadSurveyData(schoolId: String, title: String, place: String, details: String, image: UIImage) -> Observable<ResultAlert> {
        return Observable.create { [weak self] observer in
            guard let imageData = image.jpegData(compressionQuality: 0.01) else {
                return ResultAlert(title: "画像の圧縮に失敗しました", text: "時間を空けてもう一度お試しください") as! Disposable
            }
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/ipeg"
            
            let imageID = NSUUID().uuidString // Unique string to reference image
            let imageRef = Storage.storage().reference(forURL: "gs://strelitzia-8e9cf.appspot.com").child(imageID)
            
            DispatchQueue.global(qos: .default).async {
                imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
                    if error != nil {
                        let data = ResultAlert(title: "画像の保存に失敗しました", text: "時間を空けてもう一度お試しください")
                        observer.onNext(data)
                    }
                    
                    imageRef.downloadURL { (url, error) in
                        if error != nil {
                            let data = ResultAlert(title: "画像の保存に失敗しました", text: "時間を空けてもう一度お試しください")
                            observer.onNext(data)
                        } else {
                            let newFolder: [String: Any] = [
                                "userId": Auth.auth().currentUser?.uid ?? "",
                                "title": title,
                                "place": place,
                                "details": details,
                                "imageURL": url?.absoluteString as Any,
                                "imageReference": imageID,
                                "isCompleted": false,
                                "pointReceived": false,
                                "lastModified": Timestamp()
                            ]
                            
                            self?.ref.collection("school").document(schoolId).collection("survey").addDocument(data: newFolder) { error in
                                DispatchQueue.main.async {
                                    if error != nil {
                                        let data = ResultAlert(title: "エラーが起きました", text: "時間を空けてもう一度お試しください")
                                        observer.onNext(data)
                                    } else {
                                        let data = ResultAlert(title: "送信に成功しました", text: "")
                                        observer.onNext(data)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func uploadEditedSurveyData(schoolId: String, documentId: String, title: String, place: String, details: String, image: UIImage) -> Observable<ResultAlert> {
        return Observable.create { [weak self] observer in
            guard let imageData = image.jpegData(compressionQuality: 0.01) else {
                return ResultAlert(title: "画像の圧縮に失敗しました", text: "時間を空けてもう一度お試しください") as! Disposable
            }
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/ipeg"
            
            let imageID = NSUUID().uuidString // Unique string to reference image
            let imageRef = Storage.storage().reference(forURL: "gs://strelitzia-8e9cf.appspot.com").child(imageID)
            
            DispatchQueue.global(qos: .default).async {
                imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
                    if error != nil {
                        let data = ResultAlert(title: "画像の保存に失敗しました", text: "時間を空けてもう一度お試しください")
                        observer.onNext(data)
                    }
                    
                    imageRef.downloadURL { (url, error) in
                        if error != nil {
                            let data = ResultAlert(title: "画像の保存に失敗しました", text: "時間を空けてもう一度お試しください")
                            observer.onNext(data)
                        } else {
                            let newFolder: [String: Any] = [
                                "userId": Auth.auth().currentUser?.uid ?? "",
                                "title": title,
                                "place": place,
                                "details": details,
                                "imageURL": url?.absoluteString as Any,
                                "imageReference": imageID,
                                "lastModified": Timestamp()
                            ]
                            
                            self?.ref.collection("school").document(schoolId).collection("survey").document(documentId).updateData(newFolder) { error in
                                DispatchQueue.main.async {
                                    if error != nil {
                                        let data = ResultAlert(title: "エラーが起きました", text: "時間を空けてもう一度お試しください")
                                        observer.onNext(data)
                                    } else {
                                        let data = ResultAlert(title: "送信に成功しました", text: "")
                                        observer.onNext(data)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func changePointStatus(schoolId: String, documentId: String) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            let newFolder: [String: Any] = [
                "pointReceived": true
            ]
            
            self?.ref.collection("school").document(schoolId).collection("survey").document(documentId).updateData(newFolder) { error in
                DispatchQueue.main.async {
                    if error != nil {
                        observer.onNext(false) //送信に失敗
                    } else {
                        observer.onNext(true) //送信に成功
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

struct SchoolInfo {
    var schoolName: String
    var schoolId: String
    init(schoolName: String, schoolId: String) {
        self.schoolName = schoolName
        self.schoolId = schoolId
    }
}

struct UserHistoryData {
    var documentId: String
    var title: String
    var lastModified: Date
    var isCompleted: Bool
    var imageURL: String
    var pointReceived: Bool
    
    init(documentId: String, title: String, lastModified: Date, isCompleted: Bool, imageURL: String, pointReceived: Bool) {
        self.documentId = documentId
        self.title = title
        self.lastModified = lastModified
        self.isCompleted = isCompleted
        self.imageURL = imageURL
        self.pointReceived = pointReceived
    }
}

struct HistoryData {
    var documentId: String
    var title: String
    var lastModified: Date
    var isCompleted: Bool
    var imageURL: String
    
    init(documentId: String, title: String, lastModified: Date, isCompleted: Bool, imageURL: String) {
        self.documentId = documentId
        self.title = title
        self.lastModified = lastModified
        self.isCompleted = isCompleted
        self.imageURL = imageURL
    }
}

struct SurveyData {
    var documentId: String
    var title: String
    var place: String
    var details: String
    var imageURL: String
    var isCompleted: Bool
    
    init(documentId: String, title: String, place: String, details: String, imageURL: String, isCompleted: Bool) {
        self.documentId = documentId
        self.title = title
        self.place = place
        self.details = details
        self.imageURL = imageURL
        self.isCompleted = isCompleted
    }
}

struct ResultAlert {
    var title: String
    var text: String
    
    init(title: String, text: String) {
        self.title = title
        self.text = text
    }
}
