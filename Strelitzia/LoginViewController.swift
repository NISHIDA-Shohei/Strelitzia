//
//  LoginViewController.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/22.
//

import UIKit
import Firebase
import FirebaseUI

class LoginViewController: UIViewController {
    
    let authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [
            FUIOAuth.twitterAuthProvider()
        ]
    
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                        self.showUserInfo(user:user)
                    } else {
                        self.showLoginVC()
                    }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func showLoginVC() {
        let authUI = FUIAuth.defaultAuthUI()
        let providers = [FUIEmailAuth()]
        authUI?.providers = providers
        let authViewController = authUI!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    func showUserInfo(user:User) {
        print(user)
    }


}
