//
//  extension.swift
//  ZhiHu
//
//  Created by apple on 16/1/25.
//  Copyright © 2016年 zx. All rights reserved.
//

import Foundation

extension NSDate {
    func dayOfWeek()->String{
        let interval = self.timeIntervalSince1970
        let days = Int(interval/86400)
        let intValue = (days-3) % 7 //1970.1.1为星期四 －3使其从星期一开始
        
        switch intValue{
        case 0:
            return "星期日"
        case 1:
            return "星期一"
        case 2:
            return "星期二"
        case 3:
            return "星期三"
        case 4:
            return "星期四"
        case 5:
            return "星期五"
        case 6:
            return "星期六"
        default:
            break
        }
        return "未找到数据"
    }
}