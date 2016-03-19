//
//  TableContentViewCell.swift
//  ZhiHu
//
//  Created by apple on 16/1/26.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit

class TableContentViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imagesView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        //添加分隔线
        let btmLine = UIView(frame: CGRectMake(15,91,UIScreen.mainScreen().bounds.width-30,1))
        btmLine.backgroundColor = UIColor(red: 228/255.0, green: 228/255.0, blue: 228/255.0, alpha: 1)
        self.contentView.addSubview(btmLine)
    }

    
}
