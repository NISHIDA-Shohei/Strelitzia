//
//  themeButton.swift
//  Pazcal
//
//  Created by 西田翔平 on 2020/05/10.
//  Copyright © 2020 西田翔平. All rights reserved.
//

import UIKit

class ThemeButton: UIButton {
    
    var startColor: UIColor = UIColor.init(named: "CompletedStartColor")!
    var endColor: UIColor = UIColor.init(named: "CompletedEndColor")!
    
    func createGradient() {
        let gradientColors: [CGColor] = [startColor.cgColor, endColor.cgColor]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 15
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
//    func setShadow() {
//        self.layer.shadowOffset = CGSize(width: 0, height: 5)
//        self.layer.shadowColor = UIColor.systemGreen.cgColor
//        self.layer.shadowOpacity = 0.5
//        self.layer.shadowRadius = 5
//    }
//
//    override func layoutSubviews() {
//        super .layoutSubviews()
//        self.setTitleColor(.white, for: .normal)
//        self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
//        self.setShadow()
//        self.createGradient()
//    }
}
