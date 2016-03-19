//
//  ThemeEditorTableViewCell.swift
//  ZhiHu
//
//  Created by apple on 16/1/27.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit

class ThemeEditorTableViewCell: UITableViewCell {

    @IBOutlet weak var accessorySign: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //更改颜色
        accessorySign.tintColor = UIColor(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
        accessorySign.image = UIImage(named: "=switch")?.imageWithRenderingMode(.AlwaysTemplate)
        //添加分割线
        let btmLine = UIView(frame: CGRectMake(0,44.5,UIScreen.mainScreen().bounds.width,0.5))
        btmLine.backgroundColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1)
        
        self.contentView.addSubview(btmLine)
    }

    

}
