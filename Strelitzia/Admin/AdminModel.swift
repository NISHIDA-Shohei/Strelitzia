//
//  AdminModel.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/26.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

class AdminModel {
    
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
    
    func getHistory(schoolId: String) -> Observable<[HistoryData]> {
        return Observable.create { [weak self] observer in
            let folderRef = self?.ref.collection("school").document(schoolId).collection("survey")
            folderRef?.getDocuments {(snapshot, error) in
                if error != nil {
                    print("Document does not exist")
                } else {
                    var data = [HistoryData]()
                    for document in (snapshot?.documents)! {
                        let id = document.documentID
                        guard let title = document.data()["title"] as? String else { return }
                        guard let lastModifiedTimestamp = document.data()["lastModified"] as? Timestamp else { return }
                        guard let isCompleted = document.data()["isCompleted"] as? Bool else { return }
                        guard let imageURL = document.data()["imageURL"] as? String else { return }
                        let lastModified = lastModifiedTimestamp.dateValue()
                        data.append(HistoryData(documentId: id, title: title, lastModified: lastModified, isCompleted: isCompleted, imageURL: imageURL))
                    }
                    observer.onNext(data)
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
                                "isCompleted": false,
                                "lastModified": Timestamp()
                            ]
                            
                            self?.ref.collection("school").document(schoolId).collection("survey").document(documentId).setData(newFolder) { error in
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
    
    func changeStatus(schoolId: String, documentId: String, isCompleted: Bool) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            let newFolder: [String: Any] = [
                "isCompleted": !isCompleted
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
    
    func changeSchoolInfo(schoolId: String, schoolName: String) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            let newFolder: [String: Any] = [
                "schoolName": schoolName
            ]
            
            self?.ref.collection("school").document(schoolId).updateData(newFolder) { error in
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
