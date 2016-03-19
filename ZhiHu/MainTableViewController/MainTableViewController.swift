//
//  MainTableViewController.swift
//  ZhiHu
//
//  Created by apple on 16/1/25.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit
import SDWebImage

class MainTableViewController: UITableViewController,SDCycleScrollViewDelegate,ParallaxHeaderViewDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!

    var animator : ZFModalTransitionAnimator!
    //配置无限循环scrollerView
    var cycleScrollerView : SDCycleScrollView!
    //创建leftBarButtonItem
    var leftButton : UIBarButtonItem!
    //画圆的图表
    var loadCircleView : PNCircleChart!
    //等待的菊花视图
    var loadingView : UIActivityIndicatorView!
    //否拖拽
    var dragging = false
    //是否触发
    var triggered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置透明NavBar  导入AwsomeNavigationBar
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.clearColor())
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        leftButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .Plain, target: self.revealViewController(), action: "revealToggle:")
        leftButton.tintColor = UIColor.blackColor()
        //滑动手势
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        //点击手势
        view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        
        //设置tableView 及headerview
        self.setupTableView()
        //设置headerView
        self.setupTableHeaderView()
        if firstDisplay {
            //显示开机
            self.firstShow()
            //接收通知 刷新数据
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateData", name: "todayDataGet", object: nil)
            firstDisplay = false
        }else{
            self.updateData()
        }
        //下拉 画圆
        self.setupDropdownCircleView()
    }
    //刷新数据+设置scrollview内容
    func updateData() {
        
        //设置scrollview内容
        var images = [String]()
        var titles = [String]()
        for storyImages in dataManager.topStort {
            images.append(storyImages.image)
            titles.append(storyImages.title)
        }
        cycleScrollerView.imageURLStringsGroup = images
        cycleScrollerView.titlesGroup = titles
        
        let collectionView = cycleScrollerView.subviews.first as! UICollectionView
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
        
        self.tableView.reloadData()
    }
    func setupTableView() {
        //不显示滚动条
        self.tableView.showsVerticalScrollIndicator = false
        //预估高度 必须先加好约束才可根据内容调整
        self.tableView.estimatedRowHeight = 50
    }
    func setupTableHeaderView(){
        cycleScrollerView = SDCycleScrollView(frame: CGRectMake(0, 0, self.tableView.frame.width, 154), imageURLStringsGroup: nil)
        //无限循环
        cycleScrollerView.infiniteLoop = true
        //委托
        cycleScrollerView.delegate = self
        //6秒滚动一次
        cycleScrollerView.autoScrollTimeInterval = 6.0
        //页面切换时 下面的圆点的动画效果
        cycleScrollerView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated
        cycleScrollerView.titleLabelTextFont = UIFont(name: "STHeitiSC-Medium", size: 21)
        cycleScrollerView.titleLabelBackgroundColor = UIColor.clearColor()
        cycleScrollerView.titleLabelHeight = 60
        cycleScrollerView.titleLabelAlpha = 1
        
        //添加到ParallaxView(视差视图中--拉伸视图)
        let headerSubview : ParallaxHeaderView = ParallaxHeaderView.parallaxWebHeaderViewWithSubView(cycleScrollerView, forSize: CGSizeMake(self.tableView.frame.width, 154)) as! ParallaxHeaderView
        headerSubview.delegate = self
        
        self.tableView.tableHeaderView = headerSubview
    }
    //MARK:SDCycleScrollViewDelegate 点击头部图片跳转
    func cycleScrollView(cycleScrollView: SDCycleScrollView!, didSelectItemAtIndex index: Int) {
        //拿到web控制器
        let webViewController = self.storyboard?.instantiateViewControllerWithIdentifier("webViewController") as! WebViewController
        webViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        
        //animator初始化
        animator = ZFModalTransitionAnimator(modalViewController: webViewController)
        self.animator.dragable = true
        self.animator.behindViewAlpha = 0.7
        self.animator.behindViewScale = 0.9
        self.animator.transitionDuration = 0.7
        self.animator.direction = ZFModalTransitonDirection.Right
        
        webViewController.transitioningDelegate = self.animator
        webViewController.newsID = dataManager.topStort[index].id
        webViewController.isTopStory = true
        
        //转场
        self.presentViewController(webViewController, animated: true, completion: nil)
    }
    //MARK:ParallaxHeaderViewDelegate
    func lockDirection() {
        //滑到极限的时候 设置
        self.tableView.contentOffset.y = -154
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragging = false
    }
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dragging = true
    }
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let header = self.tableView.tableHeaderView as! ParallaxHeaderView
        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
        
        //下拉时 透明度渐变
        let color = UIColor(red: 1/255.0, green: 131/255.0, blue: 209/255.0, alpha: 1)
        let offsetY = scrollView.contentOffset.y
        let prelude : CGFloat = 90 //拖拽范围
        
        if offsetY >= -64 {//默认值 往上拉
            let alpha = min(1,(64+offsetY)/(64+prelude))
            //title的渐变
            (header.subviews[0].subviews[0] as! SDCycleScrollView).titleLabelAlpha = 1-alpha
            //刷新title才会更改
            (header.subviews[0].subviews[0].subviews[0] as! UICollectionView).reloadData()
            //navbar的渐变
           self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(alpha))
            //隐藏画圆view
            if loadCircleView.hidden != true {
                loadCircleView.hidden = true
            }
            if triggered == true && offsetY == -64 {
                triggered = false
            }
        }else{//往下拉
            let ratio = (-offsetY - 64)*2 //画圆的比例
            if ratio <= 100 {
                if triggered == false && loadCircleView.hidden == true {
                    loadCircleView.hidden = false
                }
                loadCircleView.updateChartByCurrent(ratio)//更改图标比例
            }else{
                if loadCircleView.current != 100 {
                    loadCircleView.updateChartByCurrent(100)
                }
                //第一次检测到松手
                if !dragging && !triggered {
                    loadCircleView.hidden = true
                    loadingView.startAnimating()
                    
                    dataManager.requestAllNeededData({ () -> () in
                        self.loadingView.stopAnimating()
                        
                    })
                    triggered = true
                }
            }
        }
          //依据contentOffsetY设置titleView的标题
        for separatorData in dataManager.offsetYValue {
            guard offsetY > separatorData.0 else {
                if dateLabel.text != separatorData.1{
                    dateLabel.text = separatorData.1
                }
                break
            }
        }
    }
    //设置下拉刷新相关内容
    func setupDropdownCircleView() {
        let comp1 = self.dateLabel.frame.width/2
        let comp2 = (self.dateLabel.text! as NSString).sizeWithAttributes(nil).width/2
        let loadCircleViewXPosition = comp1 - comp2 - 35//放圆圈的位置
        
        //绘制一个圆
        loadCircleView = PNCircleChart(frame: CGRect(x: loadCircleViewXPosition, y: 3, width: 15, height: 15), total: 100, current: 0, clockwise: true, shadow: false, shadowColor: nil, displayCountingLabel: false, overrideLineWidth: 1)
        loadCircleView.backgroundColor = UIColor.clearColor()
        loadCircleView.strokeColor = UIColor.whiteColor()
        loadCircleView.strokeChart()
        loadCircleView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        self.dateLabel.addSubview(loadCircleView)
        //初始化等待菊花
        loadingView = UIActivityIndicatorView(frame: CGRect(x: loadCircleViewXPosition+2.5, y: 5.5, width: 10, height: 10))
        self.dateLabel.addSubview(loadingView)
    }
    
    //第一次展示
    func firstShow(){
        //生成第二启动页面背景
        let launchView = UIView(frame: CGRectMake(0,-65,self.view.frame.width,self.view.frame.height+60))
        launchView.alpha = 0.99
        
        //得到第二启动页控制器 设置为子控制器
        let launchViewController = storyboard?.instantiateViewControllerWithIdentifier("launchViewController")
        self.addChildViewController(launchViewController!)
        
        //将第二启动页放到背景上
        launchView.addSubview(launchViewController!.view)
        self.view.addSubview(launchView)
        
        self.navigationItem.titleView?.hidden = true
        
        //动画效果：第二启动页3.5s展示过后经1.5秒删除并恢复展示NavbarTitleView
        UIView.animateWithDuration(3.5, animations: {
            ()->() in
            launchView.alpha = 1
            }) {
                [unowned self] (finished)->Void in
                UIView.animateWithDuration(0.5, animations: {
                    [unowned self] ()->() in
                    launchView.alpha = 0
                    self.navigationItem.titleView?.hidden = false
                    self.navigationItem.setLeftBarButtonItem(self.leftButton, animated: false)
                    }, completion: { (finished) -> Void in
                        launchView.removeFromSuperview()
                })
        }
    }

    // MARK: - Tableviewdatasource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataManager.contentStory.count + dataManager.pastContentStory.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        //取得已读新闻数组
        let readNewsIdArray = NSUserDefaults.standardUserDefaults().objectForKey(Keys.readNewsId) as! [String]
        //今日新闻
        if indexPath.row < dataManager.contentStory.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("tableContentViewCell") as! TableContentViewCell
            let data = dataManager.contentStory[indexPath.row]
            
            //验证是否已被点击过
            if let _ = readNewsIdArray.indexOf(data.id) {
                cell.titleLabel.textColor = UIColor.lightGrayColor()
            }else{
                cell.titleLabel.textColor = UIColor.blackColor()
            }
            
            cell.imagesView.sd_setImageWithURL(NSURL(string: data.images[0]))
            cell.titleLabel.text = data.title
            
            return cell
        }
        
        let newIndex = indexPath.row - dataManager.contentStory.count
        //如果以前的数据为0 直接返回
        guard dataManager.pastContentStory.count != 0 else{
            return UITableViewCell()
        }
        
        //每天数据 -> 时间
        if dataManager.pastContentStory[newIndex] is DateHeaderModel {
            let cell = tableView.dequeueReusableCellWithIdentifier("TableSeparatorViewCell") as! TableSeparatorViewCell
            let data = dataManager.pastContentStory[newIndex] as! DateHeaderModel
            cell.contentView.backgroundColor = UIColor(red: 1/255.0, green: 131/255.0, blue: 209/255.0, alpha: 1)
            cell.dateLabel.text = data.date
            return cell
        }
        
        //以前的新闻
        let cell = tableView.dequeueReusableCellWithIdentifier("tableContentViewCell") as! TableContentViewCell
        let data = dataManager.pastContentStory[newIndex] as! ContentStoryModel
        //验证是否已被点击过
        if let _ = readNewsIdArray.indexOf(data.id) {
            cell.titleLabel.textColor = UIColor.lightGrayColor()
        }else{
            cell.titleLabel.textColor = UIColor.blackColor()
        }
        cell.imagesView.sd_setImageWithURL(NSURL(string: data.images[0]))
        cell.titleLabel.text = data.title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //保证点击TableContentViewCell
        guard tableView.cellForRowAtIndexPath(indexPath) is TableContentViewCell else{
            return
        }
        let webViewController = self.storyboard?.instantiateViewControllerWithIdentifier("webViewController") as! WebViewController
        webViewController.index = indexPath.row
        //newID
        if indexPath.row < dataManager.contentStory.count {
            let id = dataManager.contentStory[indexPath.row].id
            webViewController.newsID = id
        }else {
            let newIndex = indexPath.row - dataManager.contentStory.count
            let id = (dataManager.pastContentStory[newIndex] as! ContentStoryModel).id
            webViewController.newsID = id
        }
        
        //取得已读新闻数组 供修改
        var readNewsIdArray = NSUserDefaults.standardUserDefaults().objectForKey(Keys.readNewsId) as! [String]
        //被查看了的新闻
        readNewsIdArray.append(webViewController.newsID)
        
        NSUserDefaults.standardUserDefaults().setObject(readNewsIdArray, forKey: Keys.readNewsId)
        
        animator = ZFModalTransitionAnimator(modalViewController: webViewController)
        self.animator.dragable = true
        self.animator.bounces = false
        self.animator.behindViewScale = 0.9
        self.animator.behindViewAlpha = 0.7
        self.animator.transitionDuration = 0.7
        self.animator.direction = ZFModalTransitonDirection.Right
        
        webViewController.transitioningDelegate = self.animator
        self.presentViewController(webViewController, animated: true, completion: nil)
    }

    
}
