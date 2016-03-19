//
//  WebViewController.swift
//  ZhiHu
//
//  Created by apple on 16/1/28.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit
import Alamofire

class WebViewController: UIViewController,UIScrollViewDelegate,ParallaxHeaderViewDelegate {

    
    var index = 1
    var newsID = ""
    var isTopStory = false
    var isThemeStory = false
    
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var webView: UIWebView!
    
    //是否含有图片 控制StatusBarStyle
    var hasImage = true
    //顶部图片的高
    var orginakHeight : CGFloat = 0
    //顶部图片的标题
    var titleLabel : myUILabel!
    //顶部图片的图片来源
    var sourceLabel : UILabel!
    //顶部图片的遮罩层
    var blurView : GradientView!
    //顶部图片
    var imageView : UIImageView!
    var refreshImageView : UIImageView!
    
    var dragging = false
    var triggered = false
    var webHeaderView : ParallaxHeaderView!
    
    //滑到对应位置时调整arrow方向
    var arrowState = false {
        didSet{
            if arrowState == true {
                guard index != 0 && isTopStory == false else {
                    return
                }
                //转完180度 需要0.2秒
                UIView.animateWithDuration(0.2){
                    ()->() in
                    self.refreshImageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                }
            }else {
                guard index != 0 && isTopStory == false else {
                    return
                }
                UIView.animateWithDuration(0.2){
                    self.refreshImageView.transform = CGAffineTransformIdentity
                }
            }
        }
    }
    //滑到对应位置时调整StatusBar
    var statusBarFlag = true {
        didSet {
            UIView.animateWithDuration(0.2){
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //避免因含有navBar而对scrollInsets做自动调整
        self.automaticallyAdjustsScrollViewInsets = false
        
        //左滑 返回手势
        self.navigationController?.interactivePopGestureRecognizer?.enabled = true
        self.webView.scrollView.delegate = self
        //隐藏滑动条
        self.webView.scrollView.showsVerticalScrollIndicator = false
    }

    override func viewWillAppear(animated: Bool) {

        loadWebView(newsID)
    }
    //加载webview
    func loadWebView(id:String) {
        dataManager.requestNewsData(id) { (data) -> () in
            //若body存在 拼接body与css后加载
            if let body = data["body"].string{
                //css 网页开发  网页布局排版等
                let css = data["css"][0].string!
                if let image = data["image"].string {
                    if let titleString = data["title"].string {
                        if let imageSource = data["image_source"].string {
                            self.loadParallaxHeader(image, imageSource: imageSource, titleSring: titleString)
                        }else{
                            self.loadParallaxHeader(image, imageSource: "(null)", titleSring: titleString)
                        }
                        self.hasImage = true
                        //刷新状态栏样式(隐藏bar)
                        self.setNeedsStatusBarAppearanceUpdate()
                        self.statusBarBackground.backgroundColor = UIColor.clearColor()
                    }
                }else {
                    self.hasImage = false
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.statusBarBackground.backgroundColor = UIColor.whiteColor()
                    
                    self.loadNormalHeader()
                }
                var html = "<html>"
                html += "<head>"
                html += "<link rel=\"stylesheet\" href="
                html += css
                html += "</head>"
                html += "<body>"
                html += body
                html += "</body>"
                html += "</html>"
                
                self.webView.loadHTMLString(html, baseURL: nil)
            }else {
                //直接使用share_url类型
                self.hasImage = false
                self.setNeedsStatusBarAppearanceUpdate()
                self.statusBarBackground.backgroundColor = UIColor.whiteColor()
                self.loadNormalHeader()
                
                let url = data["share_url"].string!
                self.webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
                
            }
        }
    }
    //加载图片
    func loadParallaxHeader(imageURL:String,imageSource:String,titleSring:String){
        imageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, 223))
        imageView.contentMode = .ScaleAspectFill//按照图片比例铺满
        imageView.sd_setImageWithURL(NSURL(string: imageURL))
        //保存frame
        orginakHeight = imageView.frame.height
        
        //title
        titleLabel = myUILabel(frame: CGRectMake(15,orginakHeight-80,self.view.frame.width-30,60))
        titleLabel.font = UIFont(name: "STHeitiSC-Medium", size: 21)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.shadowColor = UIColor.blackColor()//阴影
        titleLabel.shadowOffset = CGSizeMake(0, 1)
        titleLabel.verticalAlignment = VerticalAlignmentBottom
        titleLabel.numberOfLines = 0
        titleLabel.text = titleSring
        
        imageView.addSubview(titleLabel)
        
        //Image上的Image_sourceLabel 图片右下角的位置 显示图片的来源
        sourceLabel = UILabel(frame: CGRectMake(15,orginakHeight-22,self.view.frame.width-30,15))
        sourceLabel.font = UIFont(name: "HelveticaNeue", size: 9)
        sourceLabel.textColor = UIColor.lightTextColor()
        sourceLabel.textAlignment = NSTextAlignment.Right
        let sourceLabelText = imageSource
        sourceLabel.text = "图片:" + sourceLabelText
        
        imageView.addSubview(sourceLabel)
        
        //设置Image上的blurView -85表示屏幕外面
        blurView = GradientView(frame: CGRectMake(0, -85, self.view.frame.width, orginakHeight+85),type:TRANSPARENT_GRADIENT_TWICE_TYPE)
        //在blurView上添加"载入上一篇"Label
        let refreshLabel = UILabel(frame: CGRectMake(12,15,self.view.frame.width,45))
        refreshLabel.text = "载入上一篇"
        if index == 0 || isTopStory {
            refreshLabel.text = "已经是第一篇了"
            refreshLabel.frame = CGRectMake(0,15,self.view.frame.width,45)
        }
        refreshLabel.textAlignment = NSTextAlignment.Center
        refreshLabel.textColor = UIColor(red: 215/255.0, green: 215/255.0, blue: 215/255.0, alpha: 1)
        refreshLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        
        blurView.addSubview(refreshLabel)
        
        if refreshLabel.text != "已经是第一篇了" {
            refreshImageView = UIImageView(frame: CGRectMake(self.view.frame.width / 2 - 47, 30, 15, 15))
            refreshImageView.contentMode = UIViewContentMode.ScaleAspectFill
            refreshImageView.image = UIImage(named: "arrow")?.imageWithRenderingMode(.AlwaysTemplate)
            refreshImageView.tintColor = UIColor(red: 215/255.0, green: 215/255.0, blue: 215/255.0, alpha: 1)
            
            blurView.addSubview(refreshImageView)
            
        }
        
        imageView.addSubview(blurView)
        //使label不被遮挡
        imageView.bringSubviewToFront(titleLabel)
        imageView.bringSubviewToFront(sourceLabel)
        
        webHeaderView = ParallaxHeaderView.parallaxWebHeaderViewWithSubView(imageView, forSize: CGSizeMake(self.view.frame.width, 223)) as! ParallaxHeaderView
        webHeaderView.delegate = self
        //将ParallaxView添加到webView下层的scrollView上
        self.webView.scrollView.addSubview(webHeaderView)
    }
    
    //加载普通headerView
    func loadNormalHeader() {
        //载入上一篇label
        let refreshLabel = UILabel(frame: CGRectMake(12,-45,self.view.frame.width,45))
        refreshLabel.text = "载入上一篇"
        
        if index == 0 {
            refreshLabel.text = "已经是第一篇了"
            refreshLabel.frame = CGRectMake(0, -45, self.view.frame.width, 45)
            
        }
        refreshLabel.textAlignment = NSTextAlignment.Center
        refreshLabel.textColor = UIColor(red: 215/255.0, green: 215/255.0, blue: 215/255.0, alpha: 1)
        refreshLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        
        self.webView.scrollView.addSubview(refreshLabel)
        
        if refreshLabel.text != "已经是第一篇了" {
            //让圈圈转
            refreshImageView = UIImageView(frame: CGRectMake(self.view.frame.width/2-47, -30, 15, 15))
            refreshImageView.contentMode = UIViewContentMode.ScaleAspectFill
            refreshImageView.image = UIImage(named: "arrow")?.imageWithRenderingMode(.AlwaysTemplate)//渲染模式
            refreshImageView.tintColor = UIColor(red: 215/255.0, green: 215/255.0, blue: 215/255.0, alpha: 1)
            
            self.webView.scrollView.addSubview(refreshImageView)
        }
        
    }
    
    //MARK:ParallaxHeaderViewDelegate 设置滑动极限 修改该值需要一并更改layoutWebHeaderViewForScrollViewOffset中的对应值
    func lockDirection() {
        self.webView.scrollView.contentOffset.y = -85
    }
    //MARK:UIScrollViewDelegate 实现Parallax效果
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //判断是否有图
        if hasImage {
            let incrementY = scrollView.contentOffset.y
            if incrementY < 0 {
                titleLabel.frame.origin.y = orginakHeight - 80 - incrementY
                sourceLabel.frame.origin.y = orginakHeight - 20 - incrementY
                
                blurView.frame.origin.y = -85 - incrementY
                
                //如果下拉超过65pixels则改变图片方向
                if incrementY <= -65 {
                    arrowState = true
                    guard dragging || triggered else {
                        if index != 0 && isTopStory==false {
                            //加载新文章
                            loadNewArticle(true)
                            triggered = true
                        }
                        return
                    }
                }else {
                    arrowState = false
                }
                imageView.bringSubviewToFront(titleLabel)
                imageView.bringSubviewToFront(sourceLabel)
                
            }
            //监听contentOffsetY以改变StatusBarUI
            if incrementY > 223 {
                if statusBarFlag {
                    statusBarFlag = false
                }
                statusBarBackground.backgroundColor = UIColor.whiteColor()
            }else{
                if !statusBarFlag {
                    statusBarFlag = true
                }
                statusBarBackground.backgroundColor = UIColor.clearColor()
                
            }
            webHeaderView.layoutWebHeaderViewForScrollViewOffset(scrollView.contentOffset)
        }else{
            //没有顶部视图
            //如果下拉超过40pixels则改变图片方向
            if self.webView.scrollView.contentOffset.y <= -40 {
                arrowState = true
                guard dragging || triggered else{
                    if index != 0 {
                        loadNewArticle(true)
                        triggered = true
                    }
                    return
                }
            }else {
                arrowState = false
            }
        }
    }
    //记录下拉状态
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragging = false
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dragging = true
    }
    //MARK:加载新文章
    func loadNewArticle(previous:Bool) {
        //生成动画初始位置
        let offScreenUp = CGAffineTransformMakeTranslation(0, -self.view.frame.height)
        let offScreenDown = CGAffineTransformMakeTranslation(0, self.view.frame.height)
        
        //生成新View并传入新数据
        let toWebViewController = self.storyboard!.instantiateViewControllerWithIdentifier("webViewController") as! WebViewController
        let toView = toWebViewController.view
        toView.frame = self.view.frame
        
        //处理数据
        if isThemeStory == false {
            //找到上一篇文章的ID
            index--
            if index < dataManager.contentStory.count {
                let id = dataManager.contentStory[index].id
                toWebViewController.index = index
                toWebViewController.newsID = id
            }else {
                var newIndex = index - dataManager.contentStory.count
                //如果取到的不是文章则取上一篇
                if dataManager.pastContentStory[newIndex] is DateHeaderModel {
                    index--
                    newIndex--
                }
                //如果因上述情况newIndex = -1 则取contentStory中数据
                if newIndex > -1 {
                    let id = (dataManager.pastContentStory[newIndex] as! ContentStoryModel).id
                    toWebViewController.index = index
                    toWebViewController.newsID = id
                    
                }else {
                    let id =  dataManager.contentStory[index].id
                    toWebViewController.index = index
                    toWebViewController.newsID = id
                }
                
            }
        }else {
            index--
            let id = dataManager.themeContent!.stories[index].id
            toWebViewController.index = index
            toWebViewController.newsID = id
            toWebViewController.isThemeStory = true
            
        }
        //取得已读新闻数组以供修改
        var readNewsIdArray = NSUserDefaults.standardUserDefaults().objectForKey(Keys.readNewsId) as! [String]
        
        readNewsIdArray.append(toWebViewController.newsID)
        NSUserDefaults.standardUserDefaults().setObject(readNewsIdArray, forKey: Keys.readNewsId)
        
        //生成原View截图并添加到主View上
        let fromView = self.view.snapshotViewAfterScreenUpdates(true)
        self.view.addSubview(fromView)
        
        //将toView放置到屏幕之外并添加到主View上
        toView.transform = offScreenUp
        self.view.addSubview(toView)
        self.addChildViewController(toWebViewController)
        
        //动画开始
        UIView.animateWithDuration(0.2, animations: {
            ()->() in
            //fromView下滑出屏幕，新View滑入屏幕
            fromView.transform = offScreenDown
            toView.transform = CGAffineTransformIdentity
            }, completion: {
                (success)->() in
                //动画完成后清理底层webView、statusBarBackground，以及滑出屏幕的fromView，这里也有问题，多次加载新文章会每次留一层UIView 待解决
                self.webView.removeFromSuperview()
                self.statusBarBackground.removeFromSuperview()
                fromView.removeFromSuperview()
        })
    }
    //依据statusBarFlag返回StatusBar颜色
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        //无图
        guard hasImage else{
            return .Default
        }
        if statusBarFlag {
            return .LightContent
        }
        return .Default
    }
}


