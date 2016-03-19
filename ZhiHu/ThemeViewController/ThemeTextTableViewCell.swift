//
//  ThemeTextTableViewCell.swift
//  ZhiHu
//
//  Created by apple on 16/1/27.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit

class ThemeTextTableViewCell: UITableViewCell {

    
    @IBOutlet weak var themeTextLabel: myUILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //文字分布方式
        themeTextLabel.verticalAlignment = VerticalAlignmentTop
        //添加分割线
        let btmLine = UIView(frame: CGRectMake(15,91,UIScreen.mainScreen().bounds.width-30,1))
        self.contentView.addSubview(btmLine)
    }
    
    

}
