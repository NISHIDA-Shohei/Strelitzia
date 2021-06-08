//
//  ClipSetSchoolViewController.swift
//  Strelitzia
//
//  Created by papc-0370 on 2021/06/08.
//  Copyright (c) 2021, Phone Appli. All rights reserved.
//

import UIKit

class ClipSetSchoolViewController: UIViewController {

    @IBOutlet weak var schoolCodeTextField: UITextField!
    @IBOutlet weak var setSchoolButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidLayoutSubviews() {
        setSchoolButton.blueTheme()
    }
    
    @IBAction func onTapSetSchoolButton(_ sender: Any) {
        if let schoolId = schoolCodeTextField.text {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let clipSurveyViewController = storyboard.instantiateViewController(withIdentifier: "ClipSurveyViewController") as! ClipSurveyViewController
            clipSurveyViewController.modalPresentationStyle = .fullScreen
            clipSurveyViewController.schoolId = schoolId
            self.present(clipSurveyViewController, animated: true, completion: nil)
        }
    }
}
