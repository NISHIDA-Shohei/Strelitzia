//
//  BaseAddButton.swift
//  AdminSchoolFestivalNavi
//
//  Created by 西田翔平 on 2020/05/22.
//  Copyright © 2020 西田翔平. All rights reserved.
//

import UIKit

class BaseAddButton: UIButton {

    override func layoutSubviews() {
        super .layoutSubviews()
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(named: "SystemThemeColor")?.cgColor
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.tintColor = UIColor(named: "SystemThemeColor")
        self.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
}
