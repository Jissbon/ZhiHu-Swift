//
//  LunchViewController.swift
//  ZhiHu
//
//  Created by apple on 16/1/26.
//  Copyright © 2016年 zx. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LunchViewController: UIViewController,JSAnimatedImagesViewDataSource {

    @IBOutlet weak var animatedImageView: JSAnimatedImagesView!
    @IBOutlet weak var textLabel: UILabel!
    
    var imgData : NSData!
    
    //MARK:JSAnimatedImagesViewDataSource
    func animatedImagesNumberOfImages(animatedImagesView: JSAnimatedImagesView!) -> UInt {
        return 2
    }
    func animatedImagesView(animatedImagesView: JSAnimatedImagesView!, imageAtIndex index: UInt) -> UIImage! {
        if index == 0 {
            //如果已有下载好的图片则使用
            if let data = NSUserDefaults.standardUserDefaults().objectForKey(Keys.launchImgKey) {
                return UIImage(data: data as! NSData)
            }
            return UIImage(named: "DemoLaunchImage")
        }else{
            return UIImage(named: "DemoLaunchImage")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //如果已有下载好的文字则使用
        textLabel.text = NSUserDefaults.standardUserDefaults().objectForKey(Keys.launchTextKey) as? String
        
        Alamofire.request(.GET, launchImageURL).responseJSON { [unowned self]
            (response) -> Void in

            guard response.result.error == nil else {
                print("数据获取失败")
                return
            }
//            NSLog("\(response.result.value)")
            //拿text
            let text = JSON(response.result.value!)["text"].string!
            self.textLabel.text = text
            //保存
            NSUserDefaults.standardUserDefaults().setObject(text, forKey: Keys.launchTextKey)
            //拿图像并保存
            let launchImageURL = JSON(response.result.value!)["img"].string!
            Alamofire.request(.GET, launchImageURL).responseData({ [unowned self]
                (response) -> Void in
                
                self.imgData = response.result.value!
                NSUserDefaults.standardUserDefaults().setObject(self.imgData, forKey: Keys.launchImgKey)
            })
            
        }
        //设置自己为JSAnimatedImagesView的数据源
        animatedImageView.dataSource = self
        animatedImageView.timePerImage = 3 //动画时长
        
        //半透明遮罩层
        let blurView = UIView(frame: CGRectMake(0,0,self.view.frame.width,self.view.frame.height))
        blurView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.45)//透明度
        
        animatedImageView.addSubview(blurView)
        
        //渐变遮罩层
        let gradientView = GradientView(frame: CGRectMake(0, self.view.frame.height / 3 * 2, self.view.frame.width, self.view.frame.height / 3+1), type: TRANSPARENT_GRADIENT_TYPE)
        
        animatedImageView.addSubview(gradientView)
        
        //遮罩层透明度渐变
        UIView.animateWithDuration(2.5){
            ()->() in
            blurView.backgroundColor = UIColor.clearColor()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
}