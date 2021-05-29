//
//  BaseButton.swift
//  AdminSchoolFestivalNavi
//
//  Created by 西田翔平 on 2020/05/21.
//  Copyright © 2020 西田翔平. All rights reserved.
//

import UIKit

class BaseButton: UIButton {

    override func layoutSubviews() {
        super .layoutSubviews()
        self.layer.cornerRadius = 15
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 5
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.tintColor = UIColor.black
    }
}
