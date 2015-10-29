//
//  WHC_MoreMenuItemVC.swift
//  WHC_MenuViewDemo
//
//  Created by 吴海超 on 15/10/20.
//  Copyright © 2015年 吴海超. All rights reserved.
//

/*
*  qq:712641411
*  gitHub:https://github.com/netyouli
*  csdn:http://blog.csdn.net/windwhc/article/category/3117381
*/


import UIKit

protocol WHC_MoreMenuItemVCDelegate{
    func  WHCMoreMenuItemVC(moreVC: WHC_MoreMenuItemVC , addTitles: [String]! , addImageNames: [String]!);
}

class WHC_MoreMenuItemVC: UIViewController{

    /// 缓存菜单key
    var cacheWHCMenuKey: String!;
    /// 菜单项标题集合
    var menuItemTitles: [String]!;
    /// 菜单项图片名称集合
    var menuItemImageNames: [String]!;
    /// 代理
    var delegate: WHC_MoreMenuItemVCDelegate!;
    /// 边距
    var pading: CGFloat = 0;
    /// 菜单对象
    private var menuView: WHC_MenuView!;
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData();
        self.layoutUI();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initData(){
    
    }
    
    private func layoutUI(){
        self.navigationItem.title = "更多";
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
        self.view.backgroundColor = UIColor.themeBackgroundColor();
        let cancelBarItem = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: Selector("clickCancelItem:"));
        self.navigationItem.leftBarButtonItem = cancelBarItem;
        
        let menuViewParam = WHC_MenuViewParam.getWHCMenuViewDefaultParam(titles: self.menuItemTitles, imageNames: self.menuItemImageNames, cacheWHCMenuKey: self.cacheWHCMenuKey);
        menuViewParam.canDelete = false;
        menuViewParam.canAdd = true;
        menuViewParam.canSort = true;
        menuViewParam.cacheWHCMenuKey = self.cacheWHCMenuKey;
        self.menuView = WHC_MenuView(frame: UIScreen.mainScreen().bounds, menuViewParam: menuViewParam);
        self.menuView.isMoreMenuItem = true;
        self.view.addSubview(self.menuView);
    }

    func clickCancelItem(sender: UIBarButtonItem){
        self.delegate?.WHCMoreMenuItemVC(self,
            addTitles: self.menuView.getInsertTitles(),
            addImageNames: self.menuView.getInsertImageNames());
        self.dismissViewControllerAnimated(true, completion: nil);
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
