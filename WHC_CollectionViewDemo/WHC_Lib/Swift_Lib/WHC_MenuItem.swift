//
//  WHC_MenuItem.swift
//  CRM
//
//  Created by 吴海超 on 15/9/30.
//  Copyright © 2015年 吴海超. All rights reserved.
//

/*
*  qq:712641411
*  gitHub:https://github.com/netyouli
*  csdn:http://blog.csdn.net/windwhc/article/category/3117381
*/


import UIKit


@objc protocol WHC_MenuItemDelegate{
    func WHCMenuItemClick(item: WHC_MenuItem , title: String , index: Int);
    optional func WHCMenuItemClickDelete(item: WHC_MenuItem);
    optional func WHCMenuItemClickInsert(item: WHC_MenuItem);
}


private class WHC_UIButton:UIButton {
    /// 边距
    var pading: CGFloat = 0.0;
    /// 标题
    var title: String = "";
    /// 字体大小
    var fontSize: CGFloat = 10.0;
    /// 是否有图
    var hasImage = true;
    private func titleSize() -> CGSize{
        if self.title.characters.count > 0 {
            let txt: NSString = NSString(CString: (self.title.cStringUsingEncoding(NSUTF8StringEncoding))!,
                encoding: NSUTF8StringEncoding)!;
            return txt.sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(self.fontSize)]);
        }
        return CGSizeZero;
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        let txtSize = self.titleSize();
        var tempPading: CGFloat = self.pading;
        if self.pading < txtSize.height {
            tempPading = txtSize.height;
        }
        let x: CGFloat = (CGRectGetWidth(contentRect) - txtSize.width) / 2.0;
        var y: CGFloat = CGRectGetWidth(contentRect) - tempPading * 2.0 + self.pading * 2.0;
        if !self.hasImage {
            y = CGRectGetMinY(contentRect);
        }
        return CGRectMake(x,
            y,
            CGRectGetWidth(contentRect),
            CGRectGetHeight(contentRect) - y);
    }
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        if self.hasImage {
            let txtSize = self.titleSize();
            var tempPading: CGFloat = self.pading;
            if self.pading < txtSize.height {
                tempPading = txtSize.height;
            }
            if fontSize == 0 || title == "" {
                tempPading = self.pading;
            }
            return CGRectMake(tempPading,
                self.pading,
                CGRectGetWidth(contentRect) - tempPading * 2.0,
                CGRectGetWidth(contentRect) - tempPading * 2.0);
        }
        return CGRectZero;
    }
}

class WHC_MenuItem: UIView {
    /// 删除按钮
    private var deleteButton: UIButton!;
    /// 按钮
    private var button: WHC_UIButton!;
    /// 图片视图
    private var imageView: UIImageView!;
    /// 文字标签
    private var titleLabel: UILabel!;
    /// 标记视图
    private var markView: UIView!;
    /// 视图边距
    var viewPading: CGFloat = 10.0;
    /// 图标
    private var image: UIImage!;
    /// 删除按钮半径
    private let kWHCDeleteButtonRadius: CGFloat = 7.5;
    /// 删除按钮出现动画周期
    private let kWHCDeleteDeleteButtonAnimationTime  = 0.25;
    /// 标记视图半径
    private let kWHCMarkViewRadius: CGFloat = 7.5;
    /// 插入标记
    var insertMark = false;
    /// 下标
    var index: Int = 0;
    /// 协议
    var delegate: WHC_MenuItemDelegate?;
    /// 选中背景颜色
    var selectedBackgroundColor: UIColor = UIColor.clearColor();
    /// 正常背景颜色
    var nomarlBackgroundColor: UIColor = UIColor.clearColor();
    /// 设置标题
    var title: String = ""{
        willSet{
            self.button.title = newValue;
            self.button.setTitle(newValue, forState: .Normal);
        }
    }
    
    /// 通过图片名称设置图片
    var imageName: String!{
        willSet{
            if newValue.containsString("http") {
//                self.button.loadImageWithUrl(Account.shared.mainUrl + newValue, defaultImageName: "home_default_login");
            }else{
                if newValue.characters.count > 0{
                    self.button.setImage(UIImage(named: newValue), forState: .Normal);
                }else{
                    self.button.hasImage = false;
                }
            }
        }
    }
    
    /// 设置字体大小
    var fontSize: CGFloat = 14.0 {
        willSet{
            self.button.fontSize = newValue;
            self.button.titleLabel?.font = UIFont.systemFontOfSize(newValue);
        }
    }
    
    /// 设置标题文字颜色
    var titleColor: UIColor! {
        willSet{
            self.button.setTitleColor(newValue, forState: .Normal);
        }
    }
    
    init(frame: CGRect , pading: CGFloat) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.clearColor();
        self.viewPading = pading;
        self.initData();
        self.layoutUI();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.initData();
        self.layoutUI();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    /// 初始化数据
    func initData(){
        
    }
    
    /// 设置图片
    func setImage(image: UIImage!){
        if image != nil {
            self.button.setImage(image, forState: .Normal);
        }
    }
    
    /// 创建按钮
    private func createButton(title: String , backgroundImage: UIImage! ,sel: Selector){
        if self.deleteButton == nil {
            self.deleteButton = UIButton(type: .Custom);
            self.deleteButton.frame = CGRectMake(self.viewPading,
                self.viewPading,
                kWHCDeleteButtonRadius * 2.0,
                kWHCDeleteButtonRadius * 2.0);
            self.deleteButton.setBackgroundImage(backgroundImage, forState: .Normal);
            self.deleteButton.setTitleColor(UIColor.whiteColor(), forState: .Normal);
            self.deleteButton.addTarget(self, action: sel, forControlEvents: .TouchUpInside);
            self.deleteButton.layer.cornerRadius = kWHCDeleteButtonRadius;
            self.deleteButton.layer.masksToBounds = true;
        }
        if !self.subviews.contains(self.deleteButton){
            self.deleteButton.transform = CGAffineTransformMakeScale(0.2, 0.2);
            self.addSubview(self.deleteButton);
            UIView.animateWithDuration(kWHCDeleteDeleteButtonAnimationTime) { () -> Void in
                self.deleteButton.transform = CGAffineTransformIdentity;
            };
        }
    }
    
    /// 初始化布局
    func layoutUI(){
        self.button = WHC_UIButton(type: .Custom);
        self.button.pading = self.viewPading;
        self.button.setSize(CGSizeMake(self.width() - self.viewPading * 2.0, self.height() - self.viewPading * 2.0));
        self.button.center = CGPointMake(self.width() / 2.0, self.height() / 2.0);
        self.button.setTitleColor(UIColor.blackColor(), forState: .Normal);
        self.button.addTarget(self, action: Selector("clickUp:"), forControlEvents: .TouchUpInside);
        self.button.addTarget(self, action: Selector("clickDown:"), forControlEvents: .TouchDown);
        self.addSubview(self.button);
    }
    
    //MARK: - 菜单项设置接口
    
    /// 返回图片对象
    func imageObject() -> UIImage! {
        return self.button.imageView?.image;
    }
    
    /// 显示标记
    func showMark(){
        if self.markView == nil {
            self.markView = UIView(frame: CGRectMake(self.width() - kWHCMarkViewRadius * 2.0 - self.viewPading,
                self.viewPading, kWHCMarkViewRadius * 2.0, kWHCMarkViewRadius * 2.0));
            self.markView.layer.cornerRadius = kWHCMarkViewRadius;
            self.markView.layer.masksToBounds = true;
            self.markView.backgroundColor = UIColor.redColor();
            self.addSubview(self.markView);
        }else{
            self.markView.hidden = false;
        }
    }
    
    /// 隐藏标记
    func hideMark(){
        if self.markView != nil {
            self.markView.hidden = true;
        }
    }
    
    /// 添加删除按钮
    func addDeleteButton(){
        self.createButton("", backgroundImage: WHC_MenuView.createImage(true , size: CGSizeMake(kWHCDeleteButtonRadius * 4.0, kWHCDeleteButtonRadius * 4.0)), sel: Selector("clickDeleteButton:"));
    }
    
    /// 添加插入按钮
    func addInsertButton(){
        self.createButton("", backgroundImage: WHC_MenuView.createImage(false , size: CGSizeMake(kWHCDeleteButtonRadius * 4.0, kWHCDeleteButtonRadius * 4.0)), sel: Selector("clickInsertButton:"));
    }
    
    /// 移除删除按钮
    private func removeDeleteButton(){
        if self.deleteButton != nil {
            UIView.animateWithDuration(kWHCDeleteDeleteButtonAnimationTime,
                animations: { () -> Void in
                    self.deleteButton.transform = CGAffineTransformMakeScale(0.2, 0.2);
                },
                completion: { (finished) -> Void in
                    self.deleteButton.removeFromSuperview();
            });
        }
    }
    
    /// 还原尺寸
    func resetRect(center: CGPoint!){
        UIView.animateWithDuration(kWHCDeleteDeleteButtonAnimationTime) { () -> Void in
            if center != nil {
                self.center = center;
            }
            self.transform = CGAffineTransformIdentity;
        };
    }
    
    /// 恢复背景颜色
    func resetBackgroundColor(){
        self.backgroundColor = self.nomarlBackgroundColor;
    }
    
    /// 设置着色背景色
    func setLongPressBackgroundColor(){
        self.backgroundColor = self.selectedBackgroundColor;
        UIView.animateWithDuration(kWHCDeleteDeleteButtonAnimationTime) { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.2, 1.2);
        };
    }
    
    //MARK: - 单击按钮
    
    func clickUp(sender: UIButton){
        if self.deleteButton != nil &&
            self.subviews.contains(self.deleteButton){
                self.resetBackgroundColor();
                self.removeDeleteButton();
        }else {
            self.backgroundColor = self.nomarlBackgroundColor;
            self.delegate?.WHCMenuItemClick(self, title: self.title, index: self.index);
        }
    }
    
    func clickDown(sender: UIButton){
        guard self.deleteButton != nil &&
            self.subviews.contains(self.deleteButton) else {
//                self.nomarlBackgroundColor = self.backgroundColor!;
//                self.backgroundColor = self.selectedBackgroundColor;
                return;
        }
    }
    
    /// 响应删除按钮
    func clickDeleteButton(sender: UIButton){
        self.delegate?.WHCMenuItemClickDelete?(self);
    }
    
    /// 响应插入按钮
    func clickInsertButton(sender: UIButton){
        self.delegate?.WHCMenuItemClickInsert?(self);
    }
}
