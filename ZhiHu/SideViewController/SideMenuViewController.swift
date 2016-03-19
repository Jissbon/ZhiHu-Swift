//
//  SideMenuViewController.swift
//  ZhiHu
//
//  Created by apple on 16/1/26.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit

class SideMenuViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var blurView : GradientView!
    
    var isSelectHomeCell = true {
        didSet {
            if oldValue != isSelectHomeCell {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //添加最后一行的遮罩层
        blurView = GradientView(frame: CGRectMake(0, self.view.frame.height-50, self.view.frame.width, 50), type: TRANSPARENT_ANOTHER_GRADIENT_TYPE)
        self.view.addSubview(blurView)
        
        //基础设置
        self.view.backgroundColor = UIColor(red: 19/255.0, green: 26/255.0, blue: 32/255.0, alpha: 1)
        self.tableView.backgroundColor = UIColor(red: 19/255.0, green: 26/255.0, blue: 32/255.0, alpha: 1)
        self.tableView.separatorStyle = .None
        self.tableView.showsVerticalScrollIndicator = false//设置滑动方向
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 50.5
        
    }
    //更改StatusBar颜色
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}

//添加扩展
extension SideMenuViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.themes.count + 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("homeSideCell") as! HomeSideCell
            if isSelectHomeCell == false {
                cell.unSelectedCell()
            }else{
                cell.selectedCell()
            }
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("contentSideCell") as! ControllerSideCell
        cell.contentTitleLabel.text = dataManager.themes[indexPath.row-1].name
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //初始化状态结束 回归正常UI搭配
        if let _ = tableView.cellForRowAtIndexPath(indexPath) as? ControllerSideCell {
            isSelectHomeCell = false
        }
        //初始化状态结束 回归正常UI搭配
        if let _  = tableView.cellForRowAtIndexPath(indexPath) as? HomeSideCell {
            isSelectHomeCell = true
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //判定是否转场到主题日报文章列表
        if let nav = segue.destinationViewController as? UINavigationController {
            if let vc = nav.topViewController as? ThemeViewController {
                let index = self.tableView.indexPathForSelectedRow!.row
                vc.name = dataManager.themes[index - 1].name
                vc.id = dataManager.themes[index - 1].id
                
            }
        }
        
    }
}


