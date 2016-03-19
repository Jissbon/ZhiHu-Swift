//
//  ControllerSideCell.swift
//  ZhiHu
//
//  Created by apple on 16/1/26.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit

class ControllerSideCell : UITableViewCell {
    
    @IBOutlet weak var contentPlusImageView: UIImageView!
    @IBOutlet weak var contentTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置未选中状态cell的UI
        self.contentView.backgroundColor = UIColor(red: 19/255.0, green: 26/255.0, blue: 32/255.0, alpha: 1)
        self.contentTitleLabel.textColor = UIColor(red: 136/255.0, green: 141/255.0, blue: 145/255.0, alpha: 1)
        self.contentPlusImageView.image = UIImage(named: "plus")!.imageWithRenderingMode(.AlwaysTemplate)
        self.contentPlusImageView.tintColor = UIColor(red: 66/255.0, green: 72/255.0, blue: 77/255.0, alpha: 1)
        
        //设置选择状态的cell的UI
        let selectedView = UIView(frame: self.contentView.frame)
        selectedView.backgroundColor = UIColor(red: 12/255.0, green: 19/255.0, blue: 25/255.0, alpha: 1)
        self.selectedBackgroundView = selectedView
        self.contentTitleLabel.highlightedTextColor = UIColor.whiteColor()
    }
    
}