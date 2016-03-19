//
//  StoryModel.swift
//  ZhiHu
//
//  Created by apple on 16/1/25.
//  Copyright © 2016年 zx. All rights reserved.
//

import Foundation

//侧滑 日报列表
struct ThemeModel {
    var id : String
    var name : String
    init(id:String,name:String){
        self.id = id
        self.name = name
    }
}
//顶部滚动视图
struct TopStoryModel {
    var image : String
    var id : String
    var title : String
    init(image:String,id:String,title:String){
        self.id = id
        self.image = image
        self.title = title
    }
}
//主页内容列表
struct ContentStoryModel : PastContentStoryItem{
    var images : [String]
    var id : String
    var title : String
    init(images:[String],id:String,title:String){
        self.id = id
        self.images = images
        self.title = title
    }
}
//主页内容日期
struct DateHeaderModel : PastContentStoryItem{
    var date : String
    init(date : String){
        self.date = date
    }
}
//为了把不同类型的数据放入一个数组中 统一他们的类型
protocol PastContentStoryItem {}


struct ThemeContentModel {
    var stories: [ContentStoryModel]
    var background: String
    var editorsAvatars: [String]
    init (stories: [ContentStoryModel], background: String, editorsAvatars: [String]) {
        self.stories = stories
        self.background = background
        self.editorsAvatars = editorsAvatars
    }
}


struct Keys {
    static let launchImgKey = "launchImgKey"
    static let launchTextKey = "launchTextKey"
    static let readNewsId = "readNewsId"
}
