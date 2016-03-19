//
//  define.swift
//  ZhiHu
//
//  Created by zx on 16/1/15.
//  Copyright © 2016年 zx. All rights reserved.
//

import Foundation

//请求当天数据的URL
var requestTodayDataURL = "http://news-at.zhihu.com/api/4/news/latest"
//请求之前数据的URL "http://news.at.zhihu.com/api/4/news/before/" + componentOfURL  获取 componentOfURL 前一天的数据
var requestBeforeDataURL = "http://news.at.zhihu.com/api/4/news/before/"
//获取主题列表
var requestThemes = "http://news-at.zhihu.com/api/4/themes"
//获取 某个主题的新闻列表
var requestThemeURL = "http://news-at.zhihu.com/api/4/theme/"
//获取欢迎界面图片的 URL
var launchImageURL = "http://news-at.zhihu.com/api/4/start-image/1080*1776"
//获取 谋篇新闻的 URL
var requestNewsURL = "http://news-at.zhihu.com/api/4/news/"

//是否是第一次进入
var firstDisplay = true





