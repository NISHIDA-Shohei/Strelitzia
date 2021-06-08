//
//  ClipFunctions.swift
//  Strelitzia
//
//  Created by papc-0370 on 2021/06/08.
//  Copyright (c) 2021, Phone Appli. All rights reserved.
//

import Foundation
import UIKit

class ClipFunctions {

    func startIndicator(view: UIView) {
        let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)

        loadingIndicator.center = view.center
        let grayOutView = UIView(frame: view.frame)
        grayOutView.backgroundColor = .black
        grayOutView.alpha = 0.6

        // 他のViewと被らない値を代入
        loadingIndicator.tag = 999
        grayOutView.tag = 999

        view.addSubview(grayOutView)
        view.addSubview(loadingIndicator)
        view.bringSubviewToFront(grayOutView)
        view.bringSubviewToFront(loadingIndicator)

        loadingIndicator.startAnimating()
    }

    func dismissIndicator(view: UIView) {
        view.subviews.forEach {
            if $0.tag == 999 {
                $0.removeFromSuperview()
            }
        }
    }

    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
