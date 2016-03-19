//
//  ThemeContentTableViewCell.swift
//  ZhiHu
//
//  Created by apple on 16/1/27.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit

class ThemeContentTableViewCell: UITableViewCell {

    @IBOutlet weak var themeContentImageView: UIImageView!
    
    @IBOutlet weak var themeContentLabel: myUILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //文字分布
        themeContentLabel.verticalAlignment = VerticalAlignmentTop
        
        let btmLine = UIView(frame: CGRectMake(15,91,UIScreen.mainScreen().bounds.width - 30,1))
        btmLine.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        self.contentView.addSubview(btmLine)
        
    }

    
}
