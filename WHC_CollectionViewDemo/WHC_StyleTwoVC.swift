//
//  WHC_StyleTwoVC.swift
//  WHC_CollectionViewDemo
//
//  Created by 吴海超 on 15/10/28.
//  Copyright © 2015年 吴海超. All rights reserved.
//

/*
*  qq:712641411
*  gitHub:https://github.com/netyouli
*  csdn:http://blog.csdn.net/windwhc/article/category/3117381
*/

import UIKit

class WHC_StyleTwoVC: UIViewController , WHC_MenuViewDelegate {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "WHC-集合菜单样式二";
        self.automaticallyAdjustsScrollViewInsets = false;
        let menuParam = WHC_MenuViewParam.getWHCMenuViewDefaultParam(titles: ["WHC","公司通知","直销客户","渠道客户","拜访管理","拜访回馈","回馈问题","销售计划","项目报备","项目跟踪","合同管理","收款管理","工作小结","请假申请","费用申请","汇总统计","发布通知","客户审核","回馈批注","小结批注","报备审核","市场推广","售后服务","费用审核","请假审批","w","h","c","吴海超","吴","超","海","iOS","Android","WP","手机","苹果","大神"], imageNames: ["icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2","icon3","icon1","icon2"], cacheWHCMenuKey: "WHC-集合菜单样式二");
        menuParam.menuOrientation = .Horizontal;  // 横向布局菜单
        let menuView = WHC_MenuView(frame: CGRectMake(0, 64.0, self.view.screenWidth(), self.view.screenHeight() - 114), menuViewParam: menuParam);
        menuView.delegate = self;
        self.view.addSubview(menuView);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - WHC_MenuViewDelegate
    func WHCMenuView(menuView: WHC_MenuView ,item: WHC_MenuItem, title: String){
        print(title);
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
