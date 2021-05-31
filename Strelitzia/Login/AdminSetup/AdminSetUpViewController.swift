//
//  AdminSetUpViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/26.
//

import UIKit
import Firebase

class AdminSetUpViewController: UIViewController {
    
    @IBOutlet weak var schoolNameLabel: UITextField!
    @IBOutlet weak var setSettingButton: UIButton!
    
    var schoolId = ""
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidLayoutSubviews() {
        setSettingButton.blueTheme()
    }
    
    @IBAction func onTapSetUpButton() {
        if let schoolName = schoolNameLabel.text {
            
            let newFolder: [String: Any] = [
                "schoolName": schoolName,
                "schoolId": schoolId
            ]
            
            Firestore.firestore().collection("school").document(schoolId).setData(newFolder) { error in
                DispatchQueue.main.async {
                    if error != nil {
                        let dialog = UIAlertController(title: "登録失敗", message: error?.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(dialog, animated: true, completion: nil)
                    } else {
                        let storyboard: UIStoryboard = UIStoryboard(name: "Admin", bundle: nil)
                        let adminMainViewController = storyboard.instantiateViewController(withIdentifier: "AdminMainViewController") as! AdminMainViewController
                        adminMainViewController.modalPresentationStyle = .fullScreen
                        self.present(adminMainViewController, animated: false, completion: nil)
                    }
                }
            }
        }
    }
}
