//
//  DataManager.swift
//  ZhiHu
//
//  Created by apple on 16/1/25.
//  Copyright © 2016年 zx. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/* C中全局变量声明成static 该全局变量只有本文件可以使用*/
/* Swift中的static在方法里时 全局变量 程序开始时创建 只能在方法中访问 全局变量只有一份 */

var dataManager : DataManager {//只读计算属性
    
//     get {
        struct Singleton {//保护起来
            static var predicate : dispatch_once_t = 0
            static var instance : DataManager? = nil
        }
        dispatch_once(&Singleton.predicate, { () -> Void in
            //此处只执行一次
            Singleton.instance = DataManager()
        })
        return Singleton.instance!
//     }
}

class DataManager {
    /* 保存数据 供外面使用 */
    //MARK:数据数组
    //侧滑界面列表
    var themes : [ThemeModel] = []
    //顶部
    var topStort : [TopStoryModel] = []
    //当日新闻
    var contentStory : [ContentStoryModel] = []
    //以前的新闻＋日期
    var pastContentStory : [PastContentStoryItem] = []
    //元祖里面第一个是坐标 第二个是标题  通过偏移量展示不同的标题
    var offsetYValue : [(CGFloat,String)] = []
    
    /* 临时数据 修改内容 修改完 给保存数据赋值  目的 防止数据边修改边显示的问题 */
    
    //侧滑界面列表
    var tempThemes : [ThemeModel] = []
    //顶部
    var tempTopStort : [TopStoryModel] = []
    //当日新闻
    var tempContentStory : [ContentStoryModel] = []
    //以前的新闻＋日期
    var tempPastContentStory : [PastContentStoryItem] = []
    //元祖里面第一个是坐标 第二个是标题  通过偏移量展示不同的标题
    var tempOffsetYValue : [(CGFloat,String)] = []
    
    
    //MARK: 队列 信号量 内容数组
    let dataQueue = dispatch_queue_create("dataQueue", DISPATCH_QUEUE_SERIAL)
    let semaphore = dispatch_semaphore_create(0)
    var themeContent : ThemeContentModel?
    
    //MARK:取得主题日报数据
    //侧滑列表
    func getThemeDatas(completion : (themes : [ThemeModel])->()) {
        //[unowned self] 声明为弱引用
        //请求类似 AFNetworking 是异步执行
        Alamofire.request(.GET, requestThemes).responseJSON(completionHandler: {[unowned self] (response) -> Void in
            guard response.result.error == nil else {
            print("主题日报数据获取失败")
            return
        }
        let data = JSON(response.result.value!)["others"]
//        print("data---\(data)")
        for index in 0..<data.count {
            //Block中使用self访问实例变量
            self.themes.append(ThemeModel(id: String(data[index]["id"]), name: String(data[index]["name"])))
        }
        completion(themes: self.themes)
    })
  }
    
    //MARK:请求全部所需首页文章数据
    func requestAllNeededData(completionHandle:(()->())?) {
        //顶部数据
        self.tempTopStort.removeAll()
        //内容数据
        self.tempContentStory.removeAll()
        //以前的数据
        self.tempPastContentStory.removeAll()
        //Y的偏移量
        self.tempOffsetYValue.removeAll()
        
        dispatch_async(dataQueue) { () -> Void in
            //异步进行 数据可能不是按天的顺序加载的 所以加信号量控制
            for i in 0..<10 {
                self.requestData(dataOfDate: NSDate().dateByAddingTimeInterval(28800 - Double(i)*86400)){
                    dispatch_semaphore_signal(self.semaphore) //信号量 +1
                }
                //信号量 －1
                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
                //这里会等待(信号量<0) ,信号量＝0 线程继续运行
            }
            self.topStort = self.tempTopStort
            self.contentStory = self.tempContentStory
            self.pastContentStory = self.tempPastContentStory
            self.offsetYValue = self.tempOffsetYValue
            /*-------*/
//            print("呼呼\(self.topStort)")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                NSNotificationCenter.defaultCenter().postNotificationName("todayDataGet", object: nil)
                //回调数据
                if let completionHandle = completionHandle{
                    completionHandle()
                }
            })
        }
    }
    
    //MARK:给定日期,请求首页文章数据
    func requestData(dataOfDate date:NSDate,completionHandler:(()->())?) {
        //取出当天的数据
        //判断是不是当天 description转字符
        if getCalenderString(date.description) == getCalenderString(NSDate().dateByAddingTimeInterval(28800).description) {
            
            Alamofire.request(.GET, requestTodayDataURL).responseJSON(completionHandler: {
                (response) -> Void in
                guard response.result.error == nil else{
                    print("数据获取失败")
                    return
                }
                //JSON解析
                let data = JSON(response.result.value!)
                let topStoryData = data["top_stories"]
                let contentStoryData = data["stories"]
                
                //****数据转模型存于数组***
                
                for i in 0..<topStoryData.count {
                    self.tempTopStort.append(TopStoryModel(image: topStoryData[i]["image"].string!, id: String(topStoryData[i]["id"]), title: topStoryData[i]["title"].string!))
                }
                for i in 0..<contentStoryData.count {
                    self.tempContentStory.append(ContentStoryModel(images: [contentStoryData[i]["images"][0].string!], id: String(contentStoryData[i]["id"]), title: contentStoryData[i]["title"].string!))
                }
                //今日新闻的整个内容结束时的y  标题的位置
                self.tempOffsetYValue.append((120 + CGFloat(contentStoryData.count)*93,"今日热闻"))
                
                if let completionHandler = completionHandler {
                    completionHandler()
                }
            })
            
            
        }else{
            //之前的内容
            //请求是请求componentOfURL 前一天的数据 componentOfURL 是传入日期的后一天日期 如 传入 25号  那么 这里就是 26号
            //今日日期 26
            let componentOfURL = self.getCalenderString(date.dateByAddingTimeInterval(86400).description)
            //传入日期 25
            let calenderStringOfDate = self.getCalenderString(date.description)
//            print("当前日期:\(componentOfURL)")
//            print("传入日期:\(calenderStringOfDate)")
            //取出26号之前的数据
            Alamofire.request(.GET, requestBeforeDataURL + componentOfURL).responseJSON(completionHandler: {
                (response)->Void in
                guard response.result.error == nil else {
                    print("获取之前数据失败")
                    return
                }
                
                let data = JSON(response.result.value!)
                //标题
                let tempDateString = self.getDetailString(calenderStringOfDate) + " "+date.dayOfWeek()
                //保存日期
                self.tempPastContentStory.append(DateHeaderModel(date: tempDateString))
                
                //获取以前的数据
                let contentStoryData = data["stories"]
//                print("-------\(contentStoryData)")
                for i in 0..<contentStoryData.count {
                    self.tempPastContentStory.append(ContentStoryModel(images: [contentStoryData[i]["images"][0].string!], id: String(contentStoryData[i]["id"]), title: contentStoryData[i]["title"].string!))
                }
                
                //设置offsetYValue 坐标＋标题
                self.tempOffsetYValue.append((self.tempOffsetYValue.last!.0+45+CGFloat(contentStoryData.count)*93,tempDateString))
                //回传数据
                if let completionHandler = completionHandler{
                    completionHandler()
                }
            })
        }
    }
    
    //MARK:根据ID获取新闻
    func requestThemeData(id : String, completionHander : ((JSON)->())?){
        //获取数据
        Alamofire.request(.GET, requestThemeURL + id).responseJSON(completionHandler: {
            (response) -> Void in
            guard response.result.error == nil else {
                print("ID新闻数据获取失败")
                return
            }
            //josn 解析
            let data = JSON(response.result.value!)
            
            let storyData = data["stories"]
            var themeStory : [ContentStoryModel] = []
            
            for i in 0..<storyData.count {
                //判断是否含图
                if storyData[i]["images"] != nil {
                    themeStory.append(ContentStoryModel(images: [storyData[i]["images"][0].string!], id: String(storyData[i]["id"]), title: storyData[i]["title"].string!))
                }else{
                    //不含图
                    themeStory.append(ContentStoryModel(images: [""], id: String(storyData[i]["id"]), title: storyData[i]["title"].string!))
                }
            }
            //
            let avatarsData = data["editors"]
            var editorsAvatars : [String] = []
            for i in 0 ..< avatarsData.count {
                editorsAvatars.append(avatarsData[i]["avatar"].string!)
            }
            //注入themeContent
             self.themeContent = ThemeContentModel(stories: themeStory, background: data["background"].string!, editorsAvatars: editorsAvatars)
            if let completionHander = completionHander {
                completionHander(data)
            }
        })
    }
    
    //MARK:请求某编新闻数据
    func requestNewsData(newsID:String,completionHandler:((JSON)->())?) {
        Alamofire.request(.GET, requestNewsURL + newsID).responseJSON(completionHandler: {
            (response)->() in
            guard response.result.error == nil else {
                print("获取web失败")
                return
            }
            completionHandler?(JSON(response.result.value!))
        })
    }
    
    //MARK:日期变形相关
    func getCalenderString(dateString : String)->String{
        var calenderString = ""
        for character in dateString.characters {
            if character == " " {
                break
            }else if character != "-" {
                calenderString += "\(character)"
            }
        }
        return calenderString
    }
    //MARK:获取几月几日
    func getDetailString(dateString:String)->String{
        //拿到月
        var month = ""
        month = dateString.substringWithRange(Range(start : dateString.startIndex.advancedBy(4),end : dateString.startIndex.advancedBy(6)))
        if month.hasPrefix("0") {
            month.removeAtIndex(month.startIndex)
        }
        //拿到日
        var day = ""
        day = dateString.substringWithRange(Range(start:dateString.startIndex.advancedBy(6),end : dateString.startIndex.advancedBy(8)))
        if day.hasPrefix("0") {
            day.removeAtIndex(day.startIndex)
        }
        //拼接
        return month + "月" + day + "日"
    }
}



