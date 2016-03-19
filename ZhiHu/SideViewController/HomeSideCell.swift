//
//  HomeSideCell.swift
//  ZhiHu
//
//  Created by apple on 16/1/26.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit

class HomeSideCell : UITableViewCell {
    
    @IBOutlet weak var homeSwitchImageView: UIImageView!
    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var homeTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.homeImageView.image = UIImage(named: "home")!.imageWithRenderingMode(.AlwaysTemplate)//渲染模式
        self.homeSwitchImageView.image = UIImage(named: "switch")!.imageWithRenderingMode(.AlwaysTemplate)
        //设置cell的 ui初始化状态
        self.contentView.backgroundColor = UIColor(red: 19/255.0, green: 26/255.0, blue: 32/255.0, alpha: 1)
        //设置cell被选中的背景view及字体颜色
        let selectedView = UIView(frame: self.contentView.frame)
        selectedView.backgroundColor = UIColor(red: 12/255.0, green: 19/255.0, blue: 25/255.0, alpha: 1)
        self.selectedBackgroundView = selectedView
        
        self.selectedCell()
    }
    //字体颜色
    func selectedCell() {
        self.homeSwitchImageView.tintColor = UIColor.whiteColor()
        self.homeImageView.tintColor = UIColor.whiteColor()
        self.homeTitleLabel.textColor = UIColor.whiteColor()
    }
    
    func unSelectedCell() {
        self.homeTitleLabel.textColor = UIColor(red: 136/255.0, green: 141/255.0, blue: 145/255.0, alpha: 1)
        self.homeImageView.tintColor = UIColor(red: 136/255.0, green: 141/255.0, blue: 145/255.0, alpha: 1)
        self.homeSwitchImageView.tintColor = UIColor(red: 136/255.0, green: 141/255.0, blue: 145/255.0, alpha: 1)
    }
}