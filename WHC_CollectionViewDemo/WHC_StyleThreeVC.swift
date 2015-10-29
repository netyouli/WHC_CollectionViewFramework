//
//  WHC_StyleThreeVC.swift
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

class WHC_StyleThreeVCCell:UITableViewCell , WHC_MenuViewDelegate{
    /// 背景视图
    @IBOutlet var  backView: UIView!;
    /// 图标
    @IBOutlet var  logImageView: UIImageView!;
    /// 用户名
    @IBOutlet var  nameLabel: UILabel!;
    /// 日期
    @IBOutlet var  dataLabel: UILabel!;
    /// 底部视图
    @IBOutlet var  bottomView: UIView!;
    /// 已读未读按钮
    @IBOutlet var  localButton: UIButton!;
    /// 员工按钮
    @IBOutlet var personButton: UIButton!;
    /// 图片菜单视图
    @IBOutlet var menuView: UIView!;
    /// 图片集合菜单
    private var imageMenuView: WHC_MenuView!;
    /// 图片集合
    private var imagesUrl = [String]();
    
    private var isAutoAdapter = false;
    override func awakeFromNib() {
        super.awakeFromNib();
        self.backgroundColor = UIColor.themeBackgroundColor();
        if !self.isAutoAdapter {
            self.setWidth(self.screenWidth());
            self.autoHoriAdapter();
            self.isAutoAdapter = true;
            self.backView.layer.borderColor = UIColor.lineColor().CGColor;
            self.backView.layer.borderWidth = 0.5;
            if self.menuView.subviews.count == 0 {
                let menuParam = WHC_MenuViewParam.getWHCMenuViewDefaultParam(titles: nil, imageNames: nil , cacheWHCMenuKey: "");
                menuParam.canDelete = false;          // 不能删除
                menuParam.canSort = false;            // 不能排序
                menuParam.isGridShow = false;         // 没有网格
                menuParam.autoStretchHeight = true;   // 自动拉伸菜单自身
                menuParam.pading = 1;                 // 间隙
                self.imageMenuView = WHC_MenuView(frame: menuView.frame, menuViewParam: menuParam);
                self.imageMenuView.delegate = self;
                self.backView.addSubview(self.imageMenuView);
            }
        }
    }
    
    func displayCell(imagesName: [String], otherParam: AnyObject!) {
        self.imageMenuView.update(imagesName: imagesName, titles: nil);
        self.bottomView.setY(self.imageMenuView.maxY() + 1);
        self.backView.setHeight(self.bottomView.maxY());
        self.contentView.setHeight(self.backView.maxY());
        self.setHeight(self.contentView.height());
    }
    
    @IBAction func clickButton(sender: UIButton){
        if sender === self.localButton {
            
        }else{
            
        }
    }
    
    //MARK: - WHC_MenuViewDelegate
    func WHCMenuView(menuView: WHC_MenuView ,item: WHC_MenuItem, title: String) {
        WHC_ImageDisplayView.show(self.imageMenuView.getImages() , index: item.index , item: item , column: 4);
    }
}


class WHC_StyleThreeVC: UIViewController {
    /// cell名称
    private    let kCellName = "WHC_StyleThreeVCCell";
    /// 列表
    @IBOutlet  var tableView:UITableView!;
    
    private    let imagesName = [["png3","png4","png5","png1","png2","png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2","png3","png4","png5","png1","png2","png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2"],["png3","png4"],["png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2","png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2"],["png3","png4","png5","png1","png2"]];
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "WHC-集合菜单样式三";
        self.tableView.backgroundColor = UIColor.themeBackgroundColor();
        self.tableView.registerNib(UINib(nibName: kCellName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: kCellName);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - 列表代理
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return imagesName.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        let cell: WHC_StyleThreeVCCell? = tableView.dequeueReusableCellWithIdentifier(kCellName) as? WHC_StyleThreeVCCell;
        cell?.displayCell(self.imagesName[indexPath.row], otherParam: nil);
        return cell!.height();
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0.5;
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0.5;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell: WHC_StyleThreeVCCell? = tableView.dequeueReusableCellWithIdentifier(kCellName) as? WHC_StyleThreeVCCell;
        cell?.displayCell(self.imagesName[indexPath.row], otherParam: nil);
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: false);
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
