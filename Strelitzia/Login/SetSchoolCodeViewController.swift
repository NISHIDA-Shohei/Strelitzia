//
//  SetSchoolCodeViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/23.
//

import UIKit
import Firebase

class SetSchoolCodeViewController: UIViewController {
    
    @IBOutlet weak var schoolCodeTextField: UITextField!
    
    private let userId = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapSetSchoolCode(_ sender: Any) {
        if let code = schoolCodeTextField.text {
            Firestore.firestore().collection("users").document(userId!).setData([
                "schoolId": code
            ], merge: true, completion: { error in
                if let error = error {
                    let dialog = UIAlertController(title: "登録失敗", message: error.localizedDescription, preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(dialog, animated: true, completion: nil)
                } else {
                    let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
                    let userMainViewController = storyboard.instantiateViewController(withIdentifier: "UserMainViewController") as! UserMainViewController
                    userMainViewController.modalPresentationStyle = .fullScreen
                    self.present(userMainViewController, animated: true, completion: nil)
                }
            })
        }
    }
}
