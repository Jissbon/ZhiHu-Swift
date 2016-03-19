//
//  ThemeViewController.swift
//  ZhiHu
//
//  Created by apple on 16/1/26.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit

class ThemeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topConstant: NSLayoutConstraint!
    
    @IBOutlet weak var navTitleLabel: UILabel!
    
    var id = ""
    var name = ""
    var navImageView : UIImageView!
    var themeSubview : ParallaxHeaderView!
    var dragging = false
    var triggered = false
    var animator : ZFModalTransitionAnimator!
    var loadCircleView : PNCircleChart!
    var loadingView : UIActivityIndicatorView!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    override func viewWillAppear(animated: Bool) {
        if !firstDisplay {
            self.topConstant.constant = -44
        }else {
            self.topConstant.constant = -64
            firstDisplay = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("\(id),\(name)")
        //标题
        navTitleLabel.text = name
        //item
        let leftButton = UIBarButtonItem(image: UIImage(named: "leftArrow"), style: .Plain, target: self.revealViewController(), action: "revealToggle:")
        leftButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(leftButton, animated: false)
        
        
        
        //手势
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        dataManager.requestThemeData(id) { (data) -> () in
            //更新图片
            self.navImageView.sd_setImageWithURL(NSURL(string: data["background"].string!), completed: {
                (image,_,_,_) -> Void in
                self.themeSubview.blurViewImage = image
                //获取一张虚化图片
                self.themeSubview.refreshBlurViewForNewImage()
            })
            //刷新数据
            self.tableView.reloadData()
        }
        self.setupTableView()
        self.setupTableHeaderView()
        //navBar 透明
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.clearColor())
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.setupDropdownCircleView()
    }
    
    func setupTableView() {
        
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        
    }
    func setupTableHeaderView() {
        navImageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, 64))
        navImageView.contentMode = UIViewContentMode.ScaleAspectFill
        navImageView.clipsToBounds = true
        //视差图
        themeSubview = ParallaxHeaderView.parallaxThemeHeaderViewWithSubView(navImageView, forSize: CGSizeMake(self.view.frame.width, 64), andImage: navImageView.image) as! ParallaxHeaderView
        themeSubview.delegate = self
        
        self.tableView.tableHeaderView = themeSubview
        self.view.addSubview(tableView)
    }
    //设置下拉刷新相关内容
    func setupDropdownCircleView() {
        let comp1 = self.navTitleLabel.frame.width/2
        let comp2 = (self.navTitleLabel.text! as String).sizeWithAttributes(nil).width/2
        let loadCircleViewXPosition = comp1 - comp2 - 35 //圆圈位置
        
        loadCircleView = PNCircleChart(frame: CGRect(x: loadCircleViewXPosition, y: 3, width: 15, height: 15), total: 100, current: 0, clockwise: true, shadow: false, shadowColor: nil, displayCountingLabel: false, overrideLineWidth: 1)
        loadCircleView.backgroundColor = UIColor.clearColor()
        loadCircleView.strokeColor = UIColor.whiteColor()
        loadCircleView.strokeChart()
        loadCircleView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.navTitleLabel.addSubview(loadCircleView)
        
        //初始化下拉加载loadingView
        loadingView = UIActivityIndicatorView(frame: CGRect(x: loadCircleViewXPosition+2.5, y: 5.5, width: 10, height: 10))
        self.navTitleLabel.addSubview(loadingView)
    }
    
}
extension ThemeViewController : UITableViewDelegate,UITableViewDataSource,ParallaxHeaderViewDelegate {
    
    //MARK:ParallaxHeaderViewDelegate
    func lockDirection() {
        self.tableView.contentOffset.y = -95
    }
    
    //实现Parallax效果
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let header = self.tableView.tableHeaderView as! ParallaxHeaderView
        header.layoutThemeHeaderViewForScrollViewOffset(scrollView.contentOffset)
        let offsetY = scrollView.contentOffset.y
        if offsetY <= 0 {
            let ratio = -offsetY*2
            if ratio <= 100 {
                if triggered == false && loadCircleView.hidden == true {
                    loadCircleView.hidden = false
                }
                loadCircleView.updateChartByCurrent(ratio)
            }else {
                if loadCircleView.current != 100 {
                    loadCircleView.updateChartByCurrent(100)
                }
                //第一次松手
                if !dragging && !triggered {
                    loadCircleView.hidden = true
                    loadingView.startAnimating()
                    
                    dataManager.requestThemeData(id, completionHander: { (data) -> () in
                        //更新图片
                        self.navImageView.sd_setImageWithURL(NSURL(string: data["background"].string!), completed: {
                            (image,_,_,_)->() in
                            self.themeSubview.blurViewImage = image
                            self.themeSubview.refreshBlurViewForNewImage()
                        })
                        //刷新数据
                        self.tableView.reloadData()
                        self.loadingView.stopAnimating()
                    })
                    triggered = true
                }
            }
            if triggered == true && offsetY == 0 {
                triggered = false
            }
        }else {
            if loadCircleView.hidden != true {
                loadCircleView.hidden = true
            }
        }
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragging = false
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dragging = true
    }
    
    //MARK:UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataManager.themeContent == nil {
            return 0
        }
        return dataManager.themeContent!.stories.count + 1 //主编＋1
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let readNewsIdArray = NSUserDefaults.standardUserDefaults().objectForKey(Keys.readNewsId) as! [String]
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("themeEditorTableViewCell") as! ThemeEditorTableViewCell
            for (index,editorAvatar) in dataManager.themeContent!.editorsAvatars.enumerate() {
                let avatar = UIImageView(frame: CGRectMake(62+CGFloat(37*index), 12.5, 20, 20))
                avatar.contentMode = .ScaleAspectFill
                avatar.layer.cornerRadius = 10
                avatar.clipsToBounds = true //切割 状态栏是否盖住图片
                avatar.sd_setImageWithURL(NSURL(string: editorAvatar))
                
                cell.contentView.addSubview(avatar)
            }
            return cell
        }
        //取Story数据
        let tempContentStoryItem = dataManager.themeContent!.stories[indexPath.row-1]
        //保存图片一定存在
        guard tempContentStoryItem.images[0] != "" else {
            let cell = tableView.dequeueReusableCellWithIdentifier("themeTextTableViewCell") as! ThemeTextTableViewCell
            //验证是否被点击过
            if let _ = readNewsIdArray.indexOf(tempContentStoryItem.id) {
                cell.themeTextLabel.textColor = UIColor.lightGrayColor()
                
            }else {
                cell.themeTextLabel.textColor = UIColor.blackColor()
                
            }
            cell.themeTextLabel.text = tempContentStoryItem.title
            
            return cell
        }
        //图片存在情况
        let cell = tableView.dequeueReusableCellWithIdentifier("themeContentTableViewCell") as! ThemeContentTableViewCell
        if let _ = readNewsIdArray.indexOf(tempContentStoryItem.id) {
            cell.themeContentLabel.textColor = UIColor.lightGrayColor()
        }else{
            cell.themeContentLabel.textColor = UIColor.blackColor()
        }
        cell.themeContentLabel.text = tempContentStoryItem.title
        cell.themeContentImageView.sd_setImageWithURL(NSURL(string: tempContentStoryItem.images[0]))
        
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 45
        }
        return 92
    }
    //MARK:UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            return
        }
        
        let webViewController = self.storyboard?.instantiateViewControllerWithIdentifier("webViewController") as! WebViewController
        webViewController.newsID = dataManager.themeContent!.stories[self.tableView.indexPathForSelectedRow!.row-1].id
        webViewController.index = indexPath.row-1
        webViewController.isThemeStory = true

        //取得已读新闻数据 以供修改
        var readNewsIdArray = NSUserDefaults.standardUserDefaults().objectForKey(Keys.readNewsId) as! [String]
        //记录已被选中的ID
        readNewsIdArray.append(webViewController.newsID)
        NSUserDefaults.standardUserDefaults().setObject(readNewsIdArray, forKey: Keys.readNewsId)
        //初始化animator
        animator = ZFModalTransitionAnimator(modalViewController: webViewController)
        //可以 通过拖拽返回之前界面
        self.animator.dragable = true
        self.animator.behindViewAlpha = 0.7
        self.animator.behindViewScale = 0.9
        self.animator.transitionDuration = 0.7
        self.animator.direction = ZFModalTransitonDirection.Right
        
        //设置webViewController
        webViewController.transitioningDelegate = self.animator
        
        //实现转场
        self.presentViewController(webViewController, animated: true, completion: nil)
    }
}


