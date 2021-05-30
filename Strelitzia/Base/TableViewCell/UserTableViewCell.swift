//
//  UserTableViewCell.swift
//  Strelitzia
//
//  Created by 西田翔平 on 2021/05/25.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastModifiedLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    let shadowView = UIView()

    var cellImage: UIImageView!

    var isComplete = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        loadDesign()
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.cornerRadius = 20
        
//        view.clipsToBounds = true
//        view.addGradientBackground(firstColor: startColor, secondColor: endColor)
    }
    
    func loadDesign() {

        backgroundImageView.image = isComplete ? UIImage(named: "completeBackground") : UIImage(named: "incompleteBackground")


        if isComplete {
            print("nyan")
        } else {
            print("wan")
        }
        // shadowはこっちに受け持たせる
        shadowView.layer.cornerRadius = 20
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 4
        shadowView.layer.masksToBounds = false
        
        view.addSubview(shadowView)
        thumbnailImage.layer.masksToBounds = true
        thumbnailImage.layer.cornerRadius = 20
        thumbnailImage.contentMode = .scaleAspectFill
        
        view.layer.cornerRadius = 20
        view.layer.shadowOffset = CGSize(width: 0, height: 5)// 影の方向（width=右方向、height=下方向、CGSize.zero=方向指定なし）
        view.layer.shadowColor = isComplete ? UIColor.cyan.cgColor : UIColor.systemPink.cgColor// 影の色
        view.layer.shadowOpacity = 0.5// 影の濃さ
        view.layer.shadowRadius = 5// 影をぼかし
    }
}
